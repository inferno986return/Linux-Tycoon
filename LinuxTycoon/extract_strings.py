import re
import sys


def extract_strings(filename, min_length=5):
  ascii_strings = []
  unicode_strings = []

  with open(filename, "rb") as f:
    content = f.read()

  # 1. Extract ASCII strings (printable characters 32 to 126)
  ascii_pattern = re.compile(b"[\x20-\x7e]{" + str(min_length).encode() + b",}")
  for match in ascii_pattern.finditer(content):
    ascii_strings.append(match.group().decode("ascii", errors="ignore"))

  # 2. Extract UTF-16LE strings (common in REALbasic/Xojo binaries for wide text)
  # Look for alternating printable bytes and null bytes (00)
  unicode_pattern = re.compile(
      b"(?:[\x20-\x7e]\x00){" + str(min_length).encode() + b",}"
  )
  for match in unicode_pattern.finditer(content):
    try:
      unicode_strings.append(
          match.group().decode("utf-16le", errors="ignore")
      )
    except Exception:
      pass

  return ascii_strings, unicode_strings


if __name__ == "__main__":
  filename = "LinuxTycoon - 1.2.exe"  # Make sure this matches your file name
  print(f"Scanning {filename}...")

  try:
    ascii_str, unicode_str = extract_strings(filename)

    output_filename = "extracted_strings_output.txt"
    with open(output_filename, "w", encoding="utf-8") as out:
      out.write("=== ASCII STRINGS ===\n")
      for s in ascii_str:
        out.write(s + "\n")

      out.write("\n=== UNICODE (UTF-16LE) STRINGS ===\n")
      for s in unicode_str:
        out.write(s + "\n")

    print(
        f"Extraction complete! Found {len(ascii_str)} ASCII strings and"
        f" {len(unicode_str)} Unicode strings."
    )
    print(f"Results saved to {output_filename}.")

  except FileNotFoundError:
    print(
        f"Error: Could not find '{filename}'. Ensure the script is in the same"
        " folder as the executable."
    )