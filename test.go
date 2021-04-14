package main

import (
	"fmt"
	"net"
	"net/http"
	"os"
	"os/user"
	"path/filepath"
	"time"
)

func main() {

	// Test if current user works.
	fmt.Println("Test current user")
	u, err := user.Current()
	if err != nil {
		fmt.Printf("Error loading user: %v\n", err)
	} else {
		fmt.Printf("Loaded user %+v\n", u)
	}

	// Test time zone data - to make sure the data files are installed properly.
	fmt.Println("\nTest time zones")
	var zones = []string{"Australia/Queensland", "Europe/Berlin", "America/New_York", "Europe/Prague", "Europe/Dublin"}
	for _, zone := range zones {
		loc, err := time.LoadLocation(zone)
		if err != nil {
			fmt.Printf("Error loading time zone: %v\n", err)
		} else {
			fmt.Printf("Loaded time zone: %+v\n", loc)
			t := time.Now()
			tb := t.In(loc)
			fmt.Printf("%s in %s is %s\n", t, zone, tb)
		}
	}

	// Test name resolution
	fmt.Println("\nTest CA certs")
	const host = "www.google.com"
	addrs, err := net.LookupHost(host)
	if err != nil {
		fmt.Printf("Could not look up host %q: %v\n", host, err)
	} else {
		fmt.Printf("Addresses of host %q: %+v\n", host, addrs)
	}

	// Test that CA certs exist
	fmt.Println("\nTest CA certs")
	const site = "https://github.com/"
	resp, err := http.Get(site)
	if err != nil {
		fmt.Printf("HTTPS request to %q failed: %v\n", site, err)
	} else {
		defer resp.Body.Close()
		fmt.Printf("HTTPS server %q responded: %s\n", site, resp.Status)
	}

	// Make a temp file
	fmt.Println("\nTest temp files")
	f, err := os.CreateTemp("", "test")
	if err != nil {
		fmt.Printf("Cannot create temp file: %v\n", err)
	} else {
		defer func() {
			err := f.Close()
			if err != nil {
				fmt.Printf("Cannot close temp file: %v\n", err)
			}
		}()

		fmt.Printf("Created temp file %q\n", f.Name())
		_, err = f.WriteString("Hello\n")
		if err != nil {
			fmt.Printf("Cannot write to temp file: %v\n", err)
		}
		err = f.Sync()
		if err != nil {
			fmt.Printf("Cannot write to temp file: %v\n", err)
		}
	}

	// Make sure we can write to home dir
	fmt.Println("\nTest home directory writable")
	home := os.Getenv("HOME")
	if home == "" {
		fmt.Printf("$HOME is not set\n")
	}
	fname := filepath.Join(home, "hello.txt")
	lf, err := os.OpenFile(fname, os.O_CREATE|os.O_RDWR, 0600)
	if err != nil {
		fmt.Printf("Cannot create file: %v\n", err)
	} else {
		defer func() {
			err := lf.Close()
			if err != nil {
				fmt.Printf("Cannot close file: %v\n", err)
			}
		}()

		fmt.Printf("Created file %q\n", fname)
		_, err = lf.WriteString("Hello\n")
		if err != nil {
			fmt.Printf("Cannot write to file: %v\n", err)
		}
		err = lf.Sync()
		if err != nil {
			fmt.Printf("Cannot sync file: %v\n", err)
		}
	}

	// Check working dir
	fmt.Println("\nTest working dir")
	dir, err := os.Getwd()
	if err != nil {
		fmt.Printf("Cannot get working dir: %v\n", err)
	} else {
		fmt.Printf("Working dir is %q\n", dir)
	}

	// environment
	fmt.Println("\nTest environment")
	e := os.Environ()
	for _, ev := range e {
		fmt.Println(ev)
	}

}
