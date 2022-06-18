package com.example.deduplicator.data.daos;

import androidx.room.Dao;
import androidx.room.Insert;
import androidx.room.Query;

import com.example.deduplicator.data.models.Image;

import java.util.List;

@Dao
public interface ImageDao {
    @Insert
    void insertAll(Image... images);

    @Query("SELECT * FROM image WHERE md5Hash LIKE :md5Hash")
    List<Image> findDuplicate(String md5Hash);
}
