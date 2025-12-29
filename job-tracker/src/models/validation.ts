import { z } from "zod";

// 1. Define the validation rules
export const CreateApplicationSchema = z.object({
  company: z.string().min(1, "Company name is required"),
  role: z.string().min(1, "Job role is required"),
  status_id: z.string().uuid("Invalid status ID format"), // The UUID of the custom status
  notes: z.string().optional().nullable(),
});

// 2. Automatically generate the Type (This is what you were looking for!)
export type CreateApplicationInput = z.infer<typeof CreateApplicationSchema>;
