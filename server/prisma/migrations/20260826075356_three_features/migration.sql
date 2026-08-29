-- AlterTable
ALTER TABLE "attendance_records" ADD COLUMN     "is_late" BOOLEAN NOT NULL DEFAULT false;

-- AlterTable
ALTER TABLE "employees" ADD COLUMN     "deleted_at" TIMESTAMP(3);

-- CreateTable
CREATE TABLE "attendance_corrections" (
    "id" TEXT NOT NULL,
    "employee_id" TEXT NOT NULL,
    "company_id" TEXT NOT NULL,
    "date" TEXT NOT NULL,
    "requested_in_time" TEXT,
    "requested_out_time" TEXT,
    "reason" TEXT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'Pending',
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "attendance_corrections_pkey" PRIMARY KEY ("id")
);

-- AddForeignKey
ALTER TABLE "attendance_corrections" ADD CONSTRAINT "attendance_corrections_employee_id_fkey" FOREIGN KEY ("employee_id") REFERENCES "employees"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "attendance_corrections" ADD CONSTRAINT "attendance_corrections_company_id_fkey" FOREIGN KEY ("company_id") REFERENCES "companies"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
