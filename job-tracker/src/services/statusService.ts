// services/statusService.ts
import { createClient } from "@/dbConfig";
import { Status } from "@/models/types";

export const statusService = {
  async list(): Promise<Status[]> {
    const supabase = await createClient();

    const { data, error } = await supabase
      .from("statuses")
      .select("*")
      .order("name", { ascending: true });

    if (error) throw error;
    return data as Status[];
  },

  async create(input: { name: string; color: string }): Promise<Status> {
    const supabase = await createClient();

    const { data, error } = await supabase
      .from("statuses")
      .insert({ ...input, is_default: false })
      .select()
      .single();

    if (error) throw error;
    return data as Status;
  },

  async delete(id: string): Promise<void> {
    const supabase = await createClient();

    const { error } = await supabase.from("statuses").delete().eq("id", id);

    if (error) {
      // Postgres error code for foreign key violation
      if (error.code === "23503") {
        throw new Error(
          "Cannot delete status: It is currently assigned to one or more applications."
        );
      }
      throw error;
    }
  },
};
