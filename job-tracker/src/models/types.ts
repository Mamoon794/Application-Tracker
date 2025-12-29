export interface Status {
  id: string;
  user_id: string;
  name: string;
  color: string;
  is_default: boolean;
}

export interface ActivityLog {
  id: string;
  application_id: string;
  event_type:
    | "STATUS_CHANGE"
    | "NOTE_ADDED"
    | "ATTACHMENT_UPLOADED"
    | "INITIAL_APPLIED";
  description: string;
  created_at: string;
}

export interface Attachment {
  id: string;
  application_id: string;
  file_path: string;
  file_name: string;
  file_type: "resume" | "cover_letter" | "other";
  created_at: string;
}

export interface Application {
  id: string;
  user_id: string;
  company: string;
  role: string;
  status_id: string;
  notes: string | null;
  created_at: string;
  // Joins
  status?: Status;
  activity_log?: ActivityLog[];
  attachments?: Attachment[];
}
