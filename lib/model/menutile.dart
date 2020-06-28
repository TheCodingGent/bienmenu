class MenuTile {
  String displayName;
  String filePath;

  MenuTile(this.displayName, this.filePath);

  String formatDisplayName() {
    return this.displayName[0].toUpperCase() +
        this.displayName.substring(1) +
        ' Menu';
  }
}
