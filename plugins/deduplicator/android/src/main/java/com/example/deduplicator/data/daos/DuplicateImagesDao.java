package com.example.deduplicator.data.daos;

import androidx.room.Dao;
import androidx.room.Insert;

import com.example.deduplicator.data.models.DuplicateImages;
import com.example.deduplicator.data.models.Image;

@Dao
public interface DuplicateImagesDao {
    @Insert
    void insertAll(DuplicateImages... duplicateImages);

}
