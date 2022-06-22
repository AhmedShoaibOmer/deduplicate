
import 'dart:io';

class Duplicate {
   List<File> duplicateFiles;

  Duplicate(
    this.duplicateFiles,
  );

    List<File> getDuplicateFiles() {
        return duplicateFiles;
    }

   void setDuplicateFiles(List<File> duplicateFiles) {
        this.duplicateFiles = duplicateFiles;
    }

    
     @override
  String toString() => 'Duplicate(duplicateFiles: $duplicateFiles)';

}
