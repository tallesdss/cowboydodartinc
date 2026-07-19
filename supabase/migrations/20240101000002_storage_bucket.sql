-- Storage bucket `storage` (app uploads). public=true for getPublicUrl(); not related to public.* tables.

-- Create bucket
INSERT INTO storage.buckets (id, name, public)
SELECT 'storage', 'storage', true
WHERE NOT EXISTS (SELECT 1 FROM storage.buckets WHERE id = 'storage');

-- RLS policies for storage.objects
-- Allow authenticated users to upload to their own folder: users/{user_id}/...
DROP POLICY IF EXISTS "Users can upload own files" ON storage.objects;
CREATE POLICY "Users can upload own files"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'storage'
  AND (storage.foldername(name))[1] = 'users'
  AND (storage.foldername(name))[2] = auth.uid()::text
);

-- Allow users to update their own files (avatar upsert)
DROP POLICY IF EXISTS "Users can update own files" ON storage.objects;
CREATE POLICY "Users can update own files"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'storage'
  AND (storage.foldername(name))[1] = 'users'
  AND (storage.foldername(name))[2] = auth.uid()::text
);

-- Allow users to delete their own files
DROP POLICY IF EXISTS "Users can delete own files" ON storage.objects;
CREATE POLICY "Users can delete own files"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'storage'
  AND (storage.foldername(name))[1] = 'users'
  AND (storage.foldername(name))[2] = auth.uid()::text
);
