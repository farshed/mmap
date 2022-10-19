// ignore_for_file: non_constant_identifier_names

import 'package:stdlibc/stdlibc.dart' as libc;

/// Possible values for the `madvise()` system call that is
/// used to give advice to the kernel about memory usage.
/// See https://man7.org/linux/man-pages/man2/madvise.2.html
abstract class Advice {
  /// No special treatment. (Default)
  static final MADV_NORMAL = libc.MADV_NORMAL;

  /// Expect page references in random order.
  static final MADV_RANDOM = libc.MADV_RANDOM;

  /// Expect page references in sequential order.
  static final MADV_SEQUENTIAL = libc.MADV_SEQUENTIAL;

  /// Expect access in the near future.
  static final MADV_WILLNEED = libc.MADV_WILLNEED;

  /// Do not expect access in the near future.
  static final MADV_DONTNEED = libc.MADV_DONTNEED;

  /// The application no longer requires the pages in the range
  /// specified by addr and len.
  static final MADV_FREE = libc.MADV_FREE;

  /// Free up a given range of pages and its associated backing store.
  static final MADV_REMOVE = libc.MADV_REMOVE;

  /// Do not make the pages in this range available to the child
  /// after a `fork(2)`.
  static final MADV_DONTFORK = libc.MADV_DONTFORK;

  /// Undo the effect of `MADV_DONTFORK`, restoring the default behavior.
  static final MADV_DOFORK = libc.MADV_DOFORK;

  /// Enable Kernel Samepage Merging (KSM) for the pages in the
  /// range specified by addr and length.
  static final MADV_MERGEABLE = libc.MADV_MERGEABLE;

  /// Undo the effect of an earlier `MADV_MERGEABLE` operation on
  /// the specified address range.
  static final MADV_UNMERGEABLE = libc.MADV_UNMERGEABLE;

  /// Enable Transparent Huge Pages (THP) for pages in the range
  /// specified by addr and length.
  static final MADV_HUGEPAGE = libc.MADV_HUGEPAGE;

  /// Ensures that memory in the address range specified by addr
  /// and length will not be backed by transparent hugepages.
  static final MADV_NOHUGEPAGE = libc.MADV_NOHUGEPAGE;

  /// **Linux only**
  ///
  /// Exclude from a core dump those pages in the range specified by addr and length.
  static final MADV_DONTDUMP = libc.MADV_DONTDUMP;

  /// **Linux only**
  ///
  /// Undo the effect of an earlier `MADV_DONTDUMP`.
  static final MADV_DODUMP = libc.MADV_DODUMP;

  /// **Linux only**
  ///
  /// Poison the pages in the range specified by addr and length
  /// and handle subsequent references to those pages like a
  /// hardware memory corruption.
  static final MADV_HWPOISON = libc.MADV_HWPOISON;

  /// **Linux only**
  ///
  /// Reclaim a given range of pages.
  static final MADV_PAGEOUT = libc.MADV_PAGEOUT;

  /// **Darwin only**
  ///
  /// Indicates that the application would like the wired pages in this address range to be
  /// zeroed out if the address range is deallocated without first unwiring the pages.
  static final MADV_ZERO_WIRED_PAGES = libc.MADV_ZERO_WIRED_PAGES;

  /// **Darwin only**
  ///
  /// Behaves like `MADV_FREE`, but the freed pages are accounted for in the RSS of the process.
  static final MADV_FREE_REUSABLE = libc.MADV_FREE_REUSABLE;

  /// **Darwin only**
  ///
  /// Marks a memory region previously freed by `MADV_FREE_REUSABLE` as non-reusable.
  static final MADV_FREE_REUSE = libc.MADV_FREE_REUSE;

  /// Alias of `MADV_NORMAL`
  static final POSIX_MADV_NORMAL = MADV_NORMAL;

  /// Alias of `POSIX_MADV_RANDOM`
  static final POSIX_MADV_RANDOM = MADV_RANDOM;

  /// Alias of `MADV_SEQUENTIAL`
  static final POSIX_MADV_SEQUENTIAL = MADV_SEQUENTIAL;

  /// Alias of `MADV_WILLNEED`
  static final POSIX_MADV_WILLNEED = MADV_WILLNEED;

  /// Alias of `MADV_DONTNEED`
  static final POSIX_MADV_DONTNEED = MADV_DONTNEED;
}


// Future expansion:
// MADV_SOFT_OFFLINE  (since Linux 2.6.33)
// MADV_WIPEONFORK  (since Linux 4.14)
// MADV_KEEPONFORK  (since Linux 4.14)
// MADV_COLD  (since Linux 5.4)
// MADV_PAGEOUT  (since Linux 5.4)

