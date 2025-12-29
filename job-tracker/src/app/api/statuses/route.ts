import { NextResponse } from "next/server";
import { statusService } from "@/services/statusService";

export async function GET() {
  const statuses = await statusService.list();
  return NextResponse.json(statuses);
}

export async function POST(req: Request) {
  const body = await req.json();
  const status = await statusService.create(body);
  return NextResponse.json(status, { status: 201 });
}
