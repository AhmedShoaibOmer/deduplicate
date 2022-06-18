package com.example.deduplicator.data.db;

import androidx.room.Database;
import androidx.room.RoomDatabase;
import androidx.room.TypeConverters;

import com.example.deduplicator.data.daos.DuplicateImagesDao;
import com.example.deduplicator.data.daos.ImageDao;
import com.example.deduplicator.data.models.DuplicateImages;
import com.example.deduplicator.data.models.Image;
import com.example.deduplicator.data.util.Converters;

@Database(entities = {Image.class, DuplicateImages.class}, version = 1, exportSchema = false)
@TypeConverters({Converters.class})
public abstract class AppDatabase extends RoomDatabase {
    public abstract ImageDao imageDao();
    public abstract DuplicateImagesDao duplicateImagesDao();
}
