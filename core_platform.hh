#pragma once

#include "core_defines.hh"

// NOTE: These must be defined by the platform layer

extern "C" {
void PlatformDrawRect(int32 x, int32 y, int32 w, int32 h, uint32 color);

void PlatformLog(const char* file, int line, const char* message);
void PlatformPanic(const char* file, int line, const char* message);

void* malloc(usize size);
void free(void* address);
}
