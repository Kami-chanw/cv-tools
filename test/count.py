import os

def count_lines(file_path):
    try:
        with open(file_path, 'r', encoding='utf-8') as file:
            return len(file.readlines())
    except Exception as e:
        print(f"Error reading {file_path}: {e}")
        return 0

def count_lines_in_directory(directory):
    total_lines = 0
    for root, _, files in os.walk(directory):
        for file in files:
            file_path = os.path.join(root, file)
            total_lines += count_lines(file_path)
    return total_lines

def main():
    current_directory = os.getcwd()
    total_lines = count_lines_in_directory(current_directory)
    print(f"Total lines in {current_directory} and its subdirectories: {total_lines}")

if __name__ == "__main__":
    main()
