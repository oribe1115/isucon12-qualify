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

type IndexChunk struct {
	From, To int
}

func IndexChunks(length int, chunkSize int) <-chan IndexChunk {
	ch := make(chan IndexChunk)

	go func() {
		defer close(ch)

		for i := 0; i < length; i += chunkSize {
			idx := IndexChunk{i, i + chunkSize}
			if length < idx.To {
				idx.To = length
			}
			ch <- idx
		}
	}()

	return ch
}

func Filter[V any](collection []V, predicate func(V, int) bool) []V {
	result := []V{}

	for i, item := range collection {
		if predicate(item, i) {
			result = append(result, item)
		}
	}

	return result
}

func main() {
	// usage:
	if len(os.Args) < 3 {
		panic("usage: go run replace.go filename newFilename")
	}
	filename := os.Args[1]
	newFilename := os.Args[2]

	input, err := os.ReadFile(filename)
	if err != nil {
		panic(err)
	}
	newFile, err := os.Create(newFilename)
	if err != nil {
		panic(err)
	}

	lines := strings.Split(string(input), "\n")
	lines = Filter(lines, func(line string, i int) bool { return strings.HasPrefix(line, "INSERT INTO player_score VALUES") })
	const bulkLimit = 5000
	for idx := range IndexChunks(len(lines), bulkLimit) {
		lines := lines[idx.From:idx.To]
		trimmedLines := make([]string, len(lines))
		for i := range lines {
			trimmedLines[i] = strings.TrimSuffix(strings.TrimPrefix(lines[i], "INSERT INTO player_score VALUES"), ";")
		}
		handle(newFile.WriteString("INSERT INTO player_score VALUES "))
		handle(newFile.WriteString(strings.Join(trimmedLines, ",")))
		handle(newFile.WriteString(";\n"))
	}
	err = newFile.Close()
	if err != nil {
		panic(err)
	}
}
