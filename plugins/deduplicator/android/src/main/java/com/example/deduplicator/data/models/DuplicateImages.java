package com.example.deduplicator.data.models;

import androidx.room.ColumnInfo;
import androidx.room.Entity;
import androidx.room.PrimaryKey;

import java.util.ArrayList;

@Entity
public class DuplicateImages {
    @PrimaryKey(autoGenerate = true)
    public int dId;

    @ColumnInfo(name = "md5Hash")
    public String md5Hash;

    @ColumnInfo(name = "paths")
    public ArrayList<String> paths;

    public DuplicateImages(String md5Hash, ArrayList<String> paths) {
        this.md5Hash = md5Hash;
        this.paths = paths;
    }

    public void addImage(Image image) {
        paths.add(image.path);
    }
}
