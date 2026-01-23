#!/usr/bin/env python3
"""
Convert Wordset dictionary data to the app's JSON format.

Usage:
1. Clone or download the Wordset dictionary:
   git clone https://github.com/wordset/wordset-dictionary.git

2. Run this script:
   python3 convert_wordset.py /path/to/wordset-dictionary/data

The script will create dictionary.json in the current directory.
"""

import json
import os
import sys
from pathlib import Path


def convert_wordset_to_app_format(wordset_data_dir: str, output_file: str = "dictionary.json"):
    """Convert Wordset JSON files to the app's dictionary format."""

    data_path = Path(wordset_data_dir)

    if not data_path.exists():
        print(f"Error: Directory not found: {wordset_data_dir}")
        sys.exit(1)

    # Find all JSON files in the data directory
    json_files = list(data_path.glob("*.json"))

    if not json_files:
        print(f"Error: No JSON files found in {wordset_data_dir}")
        sys.exit(1)

    print(f"Found {len(json_files)} JSON files to process...")

    app_dictionary = {}
    word_count = 0

    for json_file in sorted(json_files):
        print(f"Processing {json_file.name}...")

        with open(json_file, 'r', encoding='utf-8') as f:
            try:
                wordset_data = json.load(f)
            except json.JSONDecodeError as e:
                print(f"  Warning: Could not parse {json_file.name}: {e}")
                continue

        for word_key, word_data in wordset_data.items():
            # Skip if no meanings
            if 'meanings' not in word_data or not word_data['meanings']:
                continue

            # Get the actual word (use 'word' field if available, otherwise the key)
            word = word_data.get('word', word_key).lower().strip()

            # Skip empty words
            if not word:
                continue

            definitions = []

            for meaning in word_data['meanings']:
                definition = meaning.get('def', '').strip()

                # Skip empty definitions
                if not definition:
                    continue

                # Get part of speech
                pos = meaning.get('speech_part', 'unknown').strip()

                # Get example if available
                example = meaning.get('example', '')
                if example:
                    example = example.strip()

                entry = {
                    'pos': pos,
                    'def': definition
                }

                if example:
                    entry['ex'] = example

                definitions.append(entry)

            # Only add words that have at least one valid definition
            if definitions:
                # If word already exists, merge definitions
                if word in app_dictionary:
                    app_dictionary[word].extend(definitions)
                else:
                    app_dictionary[word] = definitions
                    word_count += 1

    print(f"\nProcessed {word_count} unique words")
    print(f"Writing to {output_file}...")

    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(app_dictionary, f, ensure_ascii=False, separators=(',', ':'))

    # Get file size
    file_size = os.path.getsize(output_file)
    print(f"Done! Output file size: {file_size / 1024 / 1024:.1f} MB")
    print(f"\nCopy {output_file} to your Xcode project's PatientBird folder")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 convert_wordset.py /path/to/wordset-dictionary/data")
        print("\nFirst, clone the Wordset repository:")
        print("  git clone https://github.com/wordset/wordset-dictionary.git")
        print("\nThen run this script pointing to the 'data' folder:")
        print("  python3 convert_wordset.py wordset-dictionary/data")
        sys.exit(1)

    wordset_dir = sys.argv[1]
    convert_wordset_to_app_format(wordset_dir)
