//go:build unix

package state

import (
	"errors"
	"fmt"
	"os"
	"syscall"
	"time"
)

// WithLock executes fn while holding an exclusive file lock.
func (s *FileStore) WithLock(fn func() error) error {
	f, err := os.OpenFile(s.lockPath, os.O_CREATE|os.O_RDWR, 0600)
	if err != nil {
		return fmt.Errorf("opening lock file: %w", err)
	}
	defer func() { _ = f.Close() }()

	deadline := time.Now().Add(lockTimeout)
	for {
		err := syscall.Flock(int(f.Fd()), syscall.LOCK_EX|syscall.LOCK_NB)
		if err == nil {
			break
		}
		if !errors.Is(err, syscall.EWOULDBLOCK) {
			return fmt.Errorf("acquiring lock: %w", err)
		}
		if time.Now().After(deadline) {
			return fmt.Errorf("acquiring lock: timed out after %v", lockTimeout)
		}
		time.Sleep(50 * time.Millisecond)
	}
	defer func() { _ = syscall.Flock(int(f.Fd()), syscall.LOCK_UN) }()

	return fn()
}
