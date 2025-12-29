import { statusService } from "@/services/statusService";
import { NextResponse } from "next/server";

export async function DELETE(
  request: Request,
  { params }: { params: { id: string } }
) {
  try {
    await statusService.delete(params.id);
    return new NextResponse(null, { status: 204 });
  } catch (error: any) {
    // This will return the "Status in use" error we wrote in the service
    return NextResponse.json({ error: error.message }, { status: 409 });
  }
}
