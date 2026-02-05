//go:build windows

package state

import (
	"fmt"
	"os"
	"time"

	"golang.org/x/sys/windows"
)

// WithLock executes fn while holding an exclusive file lock.
func (s *FileStore) WithLock(fn func() error) error {
	f, err := os.OpenFile(s.lockPath, os.O_CREATE|os.O_RDWR, 0600)
	if err != nil {
		return fmt.Errorf("opening lock file: %w", err)
	}
	defer func() { _ = f.Close() }()

	handle := windows.Handle(f.Fd())
	overlapped := &windows.Overlapped{}

	deadline := time.Now().Add(lockTimeout)
	for {
		// LOCKFILE_EXCLUSIVE_LOCK | LOCKFILE_FAIL_IMMEDIATELY
		err := windows.LockFileEx(handle, windows.LOCKFILE_EXCLUSIVE_LOCK|windows.LOCKFILE_FAIL_IMMEDIATELY, 0, 1, 0, overlapped)
		if err == nil {
			break
		}
		if err != windows.ERROR_LOCK_VIOLATION {
			return fmt.Errorf("acquiring lock: %w", err)
		}
		if time.Now().After(deadline) {
			return fmt.Errorf("acquiring lock: timed out after %v", lockTimeout)
		}
		time.Sleep(50 * time.Millisecond)
	}
	defer func() { _ = windows.UnlockFileEx(handle, 0, 1, 0, overlapped) }()

	return fn()
}
