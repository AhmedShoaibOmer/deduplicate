package com.example.deduplicator;

import java.util.ArrayList;

public class DuplicateImages {
private String md5Hash;
private ArrayList<Image> images;

    public DuplicateImages(String md5Hash, ArrayList<Image> images) {
        this.md5Hash = md5Hash;
        this.images = images;
    }

    public String getMd5Hash() {
        return md5Hash;
    }

    public void setMd5Hash(String md5Hash) {
        this.md5Hash = md5Hash;
    }

    public ArrayList<Image> getImages() {
        return images;
    }

    public void setImages(ArrayList<Image> images) {
        this.images = images;
    }

    public void addImages(Image image) {
        if (this.images.contains(image)) return;
        this.images.add(image);
    }
}
