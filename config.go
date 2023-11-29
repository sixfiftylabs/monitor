package main

import (
	"encoding/json"
	"os"
	"path/filepath"
)

func loadConfig() ([]Service, error) {

	exec_path, err := os.Executable()
	path := filepath.Dir(exec_path)

	fh, err := os.Open(path + "/services.json")
	if err != nil {
		return nil, err
	}
	defer fh.Close()

	var services []Service

	dec := json.NewDecoder(fh)

	if err := dec.Decode(&services); err != nil {
		return nil, err
	}

	return services, nil
}
