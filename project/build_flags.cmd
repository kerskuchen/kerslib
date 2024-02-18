SET COMMON_WARNINGS=-Wall -Wextra -Wswitch-enum 
SET COMMON_DEBUG=-g

SET GAMELIB_WEB=--target=wasm32 -fno-builtin --no-standard-libraries  
SET GAMELIB_LINKER=-Wl,--no-entry -Wl,--allow-undefined  
SET GAMELIB_EXPORTS=-Wl,--export=GameGetTitle -Wl,--export=GameInit -Wl,--export=GameScreenResize -Wl,--export=GameDoFrame -Wl,--export=GameKeyDown -Wl,--export=GameKeyUp

SET LAUNCHER_EXTRA=-MJ build/compile_commands.json
SET LAUNCHER_LINKER=-lSDL2main -lSDL2 -Xlinker /subsystem:console 

