import { NextResponse } from "next/server";
import { applicationService } from "@/services/applicationService";

export async function GET(request: Request) {
  try {
    const { searchParams } = new URL(request.url);
    const filters = {
      statusId: searchParams.get("statusId") || undefined,
      search: searchParams.get("search") || undefined,
    };

    const apps = await applicationService.list(filters);
    return NextResponse.json(apps);
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
