'use strict';

let glCanvas = document.getElementById("glCanvas");
let renderer = glCanvas.getContext("2d");
let wasm = null;
// TODO: We may need to make this dynamic in the long run
const wasmMemory = new WebAssembly.Memory({ initial: 2, maximum: 256 });


function CStringToString(cString) {
    const memoryAsBuffer = new Uint8Array(wasmMemory.buffer);
    let strLength = 0;
    let strIter = cString;
    while (memoryAsBuffer[strIter] != 0) {
        strLength++;
        strIter++;
    }
    const stringBytes = new Uint8Array(wasmMemory.buffer, cString, strLength);
    return new TextDecoder().decode(stringBytes);
}

function PlatformDrawRect(x, y, width, height, colorUint32) {
    if (colorUint32 < 0)
        colorUint32 = 0xFFFFFFFF + colorUint32 + 1;
    let colorString = "#" + colorUint32.toString(16).toUpperCase().padStart(8, '0');
    renderer.fillStyle = colorString;
    renderer.fillRect(x, y, width, height);
}

function PlatformPanic(filepathCString, line, messageCString) {
    const filepath = CStringToString(filepathCString);
    const message = CStringToString(messageCString);
    console.error(`${filepath}:${line} - ${message}`);
}

function PlatformLog(messageCString) {
    const message = CStringToString(messageCString);
    console.log(`[INFO] ${message}`);
}

let timestampPrevious = null;
function DoFrame(timestamp) {
    if (timestampPrevious !== null) {
        let deltatime = (timestamp - timestampPrevious) * 0.001;
        wasm.instance.exports.GameDoFrame(deltatime, glCanvas.width, glCanvas.height);
    }
    timestampPrevious = timestamp;
    window.requestAnimationFrame(DoFrame);
}

WebAssembly.instantiateStreaming(fetch('game.wasm'), {
    env: {
        PlatformDrawRect,
        PlatformPanic,
        PlatformLog,
        memory: wasmMemory,
    }
}).then((w) => {
    wasm = w;

    document.title = CStringToString(wasm.instance.exports.GameGetTitle());
    wasm.instance.exports.GameInit(glCanvas.width, glCanvas.height);

    document.addEventListener('keydown', (e) => {
        wasm.instance.exports.GameKeyDown(e.key.charCodeAt());
    });
    document.addEventListener('keyup', (e) => {
        wasm.instance.exports.GameKeyUp(e.key.charCodeAt());
    });

    window.requestAnimationFrame(DoFrame);
});