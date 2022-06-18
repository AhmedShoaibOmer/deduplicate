package com.example.deduplicator.data.models;

import androidx.room.ColumnInfo;
import androidx.room.Entity;
import androidx.room.PrimaryKey;

@Entity
public class Image {
    @PrimaryKey(autoGenerate = true)
    public int iId;

    @ColumnInfo(name = "path")
    public String path;

    @ColumnInfo(name = "md5Hash")
    public String md5Hash;

    public Image(String path, String md5Hash) {
        this.path = path;
        this.md5Hash = md5Hash;
    }
}
