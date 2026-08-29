-- CreateTable
CREATE TABLE "companies" (
    "id" TEXT NOT NULL,
    "company_name" TEXT NOT NULL,
    "company_hr" TEXT NOT NULL,
    "company_code" TEXT NOT NULL,
    "company_city" TEXT NOT NULL,
    "hr_phone" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "companies_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "employees" (
    "id" TEXT NOT NULL,
    "employee_name" TEXT NOT NULL,
    "employee_number" TEXT NOT NULL,
    "employee_position" TEXT NOT NULL,
    "employee_code" TEXT NOT NULL,
    "company_id" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "employees_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "locations" (
    "id" TEXT NOT NULL,
    "company_id" TEXT NOT NULL,
    "latitude" DECIMAL(65,30) NOT NULL,
    "longitude" DECIMAL(65,30) NOT NULL,
    "radius" INTEGER NOT NULL,
    "work_start_time" TEXT,

    CONSTRAINT "locations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "attendance_records" (
    "id" TEXT NOT NULL,
    "employee_id" TEXT NOT NULL,
    "date" TEXT NOT NULL,
    "in_time" TEXT NOT NULL,
    "out_time" TEXT NOT NULL,
    "is_present" BOOLEAN NOT NULL DEFAULT false,

    CONSTRAINT "attendance_records_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "staff_counts" (
    "id" TEXT NOT NULL,
    "company_id" TEXT NOT NULL,
    "in_count" INTEGER NOT NULL DEFAULT 0,
    "out_count" INTEGER NOT NULL DEFAULT 0,
    "total" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "staff_counts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "staff_report_entries" (
    "id" TEXT NOT NULL,
    "company_id" TEXT NOT NULL,
    "is_submit" BOOLEAN NOT NULL,
    "total_count" INTEGER NOT NULL,
    "current_date" TEXT NOT NULL,

    CONSTRAINT "staff_report_entries_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "leaves" (
    "id" TEXT NOT NULL,
    "employee_id" TEXT NOT NULL,
    "company_id" TEXT NOT NULL,
    "leave_type" TEXT NOT NULL,
    "from_date" TEXT NOT NULL,
    "to_date" TEXT NOT NULL,
    "reason" TEXT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'Pending',
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "leaves_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "otps" (
    "id" TEXT NOT NULL,
    "phone_number" TEXT NOT NULL,
    "otp" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "otps_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "companies_company_name_key" ON "companies"("company_name");

-- CreateIndex
CREATE UNIQUE INDEX "companies_company_code_key" ON "companies"("company_code");

-- CreateIndex
CREATE UNIQUE INDEX "companies_hr_phone_key" ON "companies"("hr_phone");

-- CreateIndex
CREATE UNIQUE INDEX "employees_employee_number_key" ON "employees"("employee_number");

-- CreateIndex
CREATE UNIQUE INDEX "employees_employee_code_key" ON "employees"("employee_code");

-- CreateIndex
CREATE UNIQUE INDEX "employees_employee_name_company_id_key" ON "employees"("employee_name", "company_id");

-- CreateIndex
CREATE UNIQUE INDEX "locations_company_id_key" ON "locations"("company_id");

-- CreateIndex
CREATE UNIQUE INDEX "attendance_records_employee_id_date_key" ON "attendance_records"("employee_id", "date");

-- CreateIndex
CREATE UNIQUE INDEX "staff_counts_company_id_key" ON "staff_counts"("company_id");

-- CreateIndex
CREATE UNIQUE INDEX "otps_phone_number_key" ON "otps"("phone_number");

-- AddForeignKey
ALTER TABLE "employees" ADD CONSTRAINT "employees_company_id_fkey" FOREIGN KEY ("company_id") REFERENCES "companies"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "locations" ADD CONSTRAINT "locations_company_id_fkey" FOREIGN KEY ("company_id") REFERENCES "companies"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "attendance_records" ADD CONSTRAINT "attendance_records_employee_id_fkey" FOREIGN KEY ("employee_id") REFERENCES "employees"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "staff_counts" ADD CONSTRAINT "staff_counts_company_id_fkey" FOREIGN KEY ("company_id") REFERENCES "companies"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "staff_report_entries" ADD CONSTRAINT "staff_report_entries_company_id_fkey" FOREIGN KEY ("company_id") REFERENCES "companies"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "leaves" ADD CONSTRAINT "leaves_employee_id_fkey" FOREIGN KEY ("employee_id") REFERENCES "employees"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "leaves" ADD CONSTRAINT "leaves_company_id_fkey" FOREIGN KEY ("company_id") REFERENCES "companies"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
