#pragma once

////////////////////////////////////////////////////////////////////////////////////////////////////
// NOTE:
//
// KERS_INTERNAL:
//   0 - Build for public release
//   1 - Build for developer only
//
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
// Types

#include <stdarg.h>
#include <stdint.h>
#include <stddef.h>
#include <limits.h>

typedef int8_t ibyte;
typedef int8_t int8;
typedef int16_t int16;
typedef int32_t int32;
typedef int64_t int64;

typedef uint8_t byte;
typedef uint8_t uint8;
typedef uint16_t uint16;
typedef uint32_t uint32;
typedef uint64_t uint64;

typedef uint8_t bool8;
typedef uint16_t bool16;
typedef uint32_t bool32;
typedef uint64_t bool64;

typedef unsigned int uint;
typedef size_t usize;

#define internal static
#define localpersist static
#define globalvariable static

#if KERS_PLATFORM_WINDOWS
#define forceinline __forceinline
#else
#define forceinline inline
#endif

struct MemorySlice {
  void* base;
  usize size;
};

////////////////////////////////////////////////////////////////////////////////////////////////////
// Useful functions macros

// Boilerplate for MoveValue and SwapValues (see below)
template <class Type> struct __RemoveReference {
  using type = Type;
};
template <class Type> struct __RemoveReference<Type&> {
  using type = Type;
};
template <class Type> struct __RemoveReference<Type&&> {
  using type = Type;
};
template <class Type> using RemoveReference = typename __RemoveReference<Type>::type;

// Inspired by https://www.foonathan.net/2020/09/move-forward/
// This does the same thing as std::move and std::swap but saves a function call and our compile
// times by not including <utility>.
#define MoveValue(val) static_cast<decltype(val)&&>(val)
#define SwapValues(a, b)                                                                           \
  do {                                                                                             \
    RemoveReference<decltype(a)> temp = MoveValue(a);                                              \
    a                                 = MoveValue(b);                                              \
    b                                 = MoveValue(temp);                                           \
  } while (false)

#define ArrayCount(elems) (sizeof(elems) / sizeof((elems)[0]))
#define SizeOfMember(type, member) sizeof(((type*)NULL)->member)
#define OffsetOfMember(type, member) ((size_t) & (((type*)NULL)->member))

#define KiloBytes(value) ((value) * 1024LL)
#define MegaBytes(value) (KiloBytes(value) * 1024LL)
#define GigaBytes(value) (MegaBytes(value) * 1024LL)
#define TeraBytes(value) (GigaBytes(value) * 1024LL)

internal inline bool IsPowerOfTwo(usize x) { return ((x != 0) && ((x & (x - 1)) == 0)); }

internal usize RoundUpToNextPowerOfTwo(usize num) {
  usize result = 1;
  while (num > result) {
    result = result << 1;
  }

  return result;
}

template <typename Type> inline int Compare(Type& a, Type& b) {
  if (a == b)
    return 0;
  return a < b ? -1 : 1;
}
