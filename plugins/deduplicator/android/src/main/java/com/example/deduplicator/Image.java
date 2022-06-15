package com.example.deduplicator;

public class Image {
    private String path;
    private String md5Hash;

    public Image(String path, String md5Hash) {
        this.path = path;
        this.md5Hash = md5Hash;
    }

    public String getPath() {
        return path;
    }

    public void setPath(String path) {
        this.path = path;
    }

    public String getMd5Hash() {
        return md5Hash;
    }

    public void setMd5Hash(String md5Hash) {
        this.md5Hash = md5Hash;
    }
}
