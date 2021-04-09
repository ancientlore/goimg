package main

import (
	"fmt"
	"net"
	"net/http"
	"os"
	"os/user"
	"time"
)

func main() {

	// Test if current user works.
	u, err := user.Current()
	if err != nil {
		fmt.Printf("Error loading user: %v\n", err)
	} else {
		fmt.Printf("Loaded user %+v\n", u)
	}

	// Test time zone data - to make sure the data files are installed properly.
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
	const host = "www.google.com"
	addrs, err := net.LookupHost(host)
	if err != nil {
		fmt.Printf("Could not look up host %q: %v\n", host, err)
	} else {
		fmt.Printf("Addresses of host %q: %+v\n", host, addrs)
	}

	// Test that CA certs exist
	const site = "https://github.com/"
	resp, err := http.Get(site)
	if err != nil {
		fmt.Printf("HTTPS request to %q failed: %v\n", site, err)
	} else {
		defer resp.Body.Close()
		fmt.Printf("HTTPS server %q responded: %s\n", site, resp.Status)
	}

	// Make a temp file
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

	// Check working dir
	dir, err := os.Getwd()
	if err != nil {
		fmt.Printf("Cannot get working dir: %v\n", err)
	} else {
		fmt.Printf("Working dir is %q\n", dir)
	}
}
