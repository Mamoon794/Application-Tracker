import { NextResponse } from "next/server";
import { attachmentService } from "@/services/attachmentService";

export async function POST(req: Request) {
  const formData = await req.formData();
  const file = formData.get("file") as File;
  const appId = formData.get("application_id") as string;
  const type = formData.get("file_type") as any;

  const attachment = await attachmentService.upload(appId, file, type);
  return NextResponse.json(attachment);
}
