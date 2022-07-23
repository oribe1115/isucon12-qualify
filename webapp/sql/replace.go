package main

import (
	"os"
	"strings"
)

func handle(n int, err error) {
	if err != nil {
		panic(err)
	}
}

func main() {
	// usage:
	if len(os.Args) < 5 {
		panic("usage: go run replace.go filename newFilename")
	}
	filename := os.Args[3]
	newFilename := os.Args[4]

	input, err := os.ReadFile(filename)
	if err != nil {
		panic(err)
	}
	newFile, err := os.Create(newFilename)
	if err != nil {
		panic(err)
	}

	lines := strings.Split(string(input), "\n")
	const bulkLimit = 5000
	for i, line := range lines {
		if i%bulkLimit == 0 {
			handle(newFile.WriteString(strings.TrimSuffix(line, ";") + ","))
		} else {
			handle(newFile.WriteString(strings.TrimPrefix(line, "INSERT INTO player_score VALUES")))
			if i%bulkLimit != bulkLimit-1 {
				handle(newFile.WriteString(","))
			} else {
				handle(newFile.WriteString(";\n"))
			}
		}
	}
	handle(newFile.WriteString(";\n"))
	err = newFile.Close()
	if err != nil {
		panic(err)
	}
}
