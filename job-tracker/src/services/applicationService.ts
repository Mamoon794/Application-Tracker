// services/applicationService.ts
import { createClient } from "@/dbConfig";
import { Application } from "@/models/types";
import { CreateApplicationInput } from "@/models/validation";

export const applicationService = {
  async create(input: CreateApplicationInput): Promise<Application> {
    const supabase = await createClient();

    // 1. Insert Application
    const { data: app, error: appError } = await supabase
      .from("applications")
      .insert(input)
      .select(
        `
        *,
        status:statuses(*) 
      `
      )
      .single();

    if (appError) throw appError;

    // 2. Initial Timeline Entry (using your ActivityLog event_type)
    const { error: logError } = await supabase.from("activity_log").insert({
      application_id: app.id,
      event_type: "INITIAL_APPLIED",
      description: `Applied to ${app.company} as ${app.role} with status: ${app.status?.name}`,
    });

    if (logError) console.error("Failed to log activity:", logError);

    return app as Application;
  },
  async list(filters: {
    statusId?: string;
    search?: string;
  }): Promise<Application[]> {
    const supabase = await createClient();

    let query = supabase
      .from("applications")
      .select(`*, status:statuses(*)`)
      .order("created_at", { ascending: false });

    if (filters.statusId) {
      query = query.eq("status_id", filters.statusId);
    }

    if (filters.search) {
      // Searches company OR role (Requirement: Search by keyword)
      query = query.or(
        `company.ilike.%${filters.search}%,role.ilike.%${filters.search}%`
      );
    }

    const { data, error } = await query;
    if (error) throw error;
    return data as Application[];
  },

  async getById(id: string): Promise<Application> {
    const supabase = await createClient();

    const { data, error } = await supabase
      .from("applications")
      .select(
        `
        *,
        status:statuses(*),
        activity_log(*),
        attachments(*)
      `
      )
      .eq("id", id)
      .single();

    if (error) throw error;
    return data as Application;
  },
  async update(
    id: string,
    updates: { status_id?: string; notes?: string }
  ): Promise<Application> {
    const supabase = await createClient();

    const { data: oldData } = await supabase
      .from("applications")
      .select("status:statuses(name)")
      .eq("id", id)
      .select(
        `
        *,
        status:statuses(*) 
      `
      )
      .single();

    const { data: updatedApp, error } = await supabase
      .from("applications")
      .update(updates)
      .eq("id", id)
      .select(`*, status:statuses(*)`)
      .single();

    if (error) throw error;

    if (updates.status_id) {
      await supabase.from("activity_log").insert({
        application_id: id,
        event_type: "STATUS_CHANGE",
        description: `Status moved from ${oldData?.status.name} to ${updatedApp.status.name}`,
      });
    }

    if (updates.notes) {
      await supabase.from("activity_log").insert({
        application_id: id,
        event_type: "NOTE_ADDED",
        description: "Updated application notes or interview feedback",
      });
    }

    return updatedApp as Application;
  },
  async delete(id: string): Promise<void> {
    const supabase = await createClient();

    // Also deletes activity log for that application
    const { error } = await supabase.from("applications").delete().eq("id", id);

    if (error) throw error;
  },
};
