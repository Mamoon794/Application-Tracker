import { createClient } from "@/dbConfig";
import { Attachment } from "@/models/types";

export const attachmentService = {
  async upload(
    appId: string,
    file: File,
    type: "resume" | "cover_letter" | "other"
  ): Promise<Attachment> {
    const supabase = await createClient();
    const filePath = `${appId}/${Date.now()}_${file.name}`;

    // 1. Upload to Storage
    const { error: storageError } = await supabase.storage
      .from("job-documents")
      .upload(filePath, file);
    if (storageError) throw storageError;

    // 2. Create DB Record
    const { data, error: dbError } = await supabase
      .from("attachments")
      .insert({
        application_id: appId,
        file_path: filePath,
        file_name: file.name,
        file_type: type,
      })
      .select()
      .single();

    if (dbError) throw dbError;

    // 3. Log to Activity (Requirement: Timeline)
    await supabase.from("activity_log").insert({
      application_id: appId,
      event_type: "ATTACHMENT_UPLOADED",
      description: `Uploaded ${type}: ${file.name}`,
    });

    return data;
  },
  async delete(id: string): Promise<void> {
    const supabase = await createClient();

    // 1. Get the file path first to delete from Storage
    const { data: attachment, error: fetchError } = await supabase
      .from("attachments")
      .select("file_path")
      .eq("id", id)
      .single();

    if (fetchError || !attachment) throw new Error("Attachment not found");

    // 2. Delete from Supabase Storage bucket
    const { error: storageError } = await supabase.storage
      .from("job-documents")
      .remove([attachment.file_path]);

    if (storageError) throw storageError;

    // 3. Delete the database record
    const { error: dbError } = await supabase
      .from("attachments")
      .delete()
      .eq("id", id);

    if (dbError) throw dbError;
  },
};
