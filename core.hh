#pragma once

#include "core_defines.hh"
#include "core_platform.hh"

#define Malloc malloc
#define Free free
void* operator new(usize size) { return Malloc(size); }
void operator delete(void* address) noexcept { Free(address); }

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-parameter"
#pragma clang diagnostic ignored "-Weverything"
#define STB_SPRINTF_STATIC
#define STB_SPRINTF_IMPLEMENTATION
#define STB_SPRINTF_NOUNALIGNED
#define STB_SPRINTF_DECORATE(name) stb_##name
#include "thirdparty/stb_sprintf.h"
#pragma clang diagnostic pop

////////////////////////////////////////////////////////////////////////////////////////////////////
// Assertions, logging etc.

#if KERS_PLATFORM_WINDOWS && KERS_INTERNAL
#define DebugTrap() __debugbreak()
#else
#define DebugTrap()
#endif

void LogMessage(bool panic, const char* file, int line, const char* message, ...) {
  va_list args;
  va_start(args, message);
  int numBytes = stb_vsnprintf(nullptr, 0, message, args);
  va_end(args);

  usize buffersize       = numBytes + 1; // NOTE: +1 for zero terminator
  char* formattedMessage = (char*)Malloc(buffersize);

  va_start(args, message);
  stb_vsnprintf(formattedMessage, buffersize, message, args);
  va_end(args);

  PlatformLog(file, line, formattedMessage);
  if (panic)
    PlatformPanic(file, line, formattedMessage);

  Free(formattedMessage);
}

#define LogInfo(fmt, ...) LogMessage(false, __FILE__, __LINE__, "[Info] " fmt, ##__VA_ARGS__)
#define LogWarn(fmt, ...) LogMessage(false, __FILE__, __LINE__, "[Warn] " fmt, ##__VA_ARGS__)
#define LogError(fmt, ...) LogMessage(false, __FILE__, __LINE__, "[Error] " fmt, ##__VA_ARGS__)
#define LogFatal(fmt, ...) LogMessage(true, __FILE__, __LINE__, "[Fatal] " fmt, ##__VA_ARGS__)

#define Unimplemented() PlatformPanic(__FILE__, __LINE__, "Unimplemented")
#define Unreachable() PlatformPanic(__FILE__, __LINE__, "Unreachable")

#if KERS_INTERNAL

#define Assert(condition) AssertM(condition, "Assertion failed")
#define AssertM(condition, message, ...)                                                           \
  do {                                                                                             \
    if (condition) {                                                                               \
      /* Nothing to do here */                                                                     \
    } else {                                                                                       \
      DebugTrap();                                                                                 \
      PlatformPanic(__FILE__, __LINE__, message, ##__VA_ARGS__);                                   \
    }                                                                                              \
  } while (0)

#else

#define Assert(condition)
#define AssertM(condition, message, ...)

#endif
