//pc ip address
const PC_IP = "192.168.56.1";
const PC_IP2 = " 192.168.206.104";
// const PC_IP = "10.0.0.95";

// OTP Verification
const send_OTP_baseUrl = "http://$PC_IP/api/send-otp";
const verify_OTP_baseUrl = "http://$PC_IP/api/verify-otp";

//company setup
const add_company_baseUrl = "http://$PC_IP/company/add-company";
const login_company_baseUrl = "http://$PC_IP/company/login-company";

// set location
const set_location_baseUrl = "http://$PC_IP/location/store-location";

//get location
const get_location_baseUrl = "http://$PC_IP/location/get-location";

//employee add and setup
const add_employee_baseURl = "http://$PC_IP/employee/add-employee";
const login_employee_baseURl = "http://$PC_IP/employee/join-employee";

//mark attendance
const mark_attendance_url = "http://$PC_IP/attendance/mark";

//get attendance
const get_attendance_url = "http://$PC_IP/attendance/get-attend";
const get_attendance_days_url = "http://$PC_IP/attendance/get-attend-days";

//get report
const report_employee_baseURl = "http://$PC_IP/employee/get-history";
const report_company_baseURl = "http://$PC_IP/company/get-report";

//get count
const staff_count = "http://$PC_IP/employee/get-count";
const staff_change_count = "http://$PC_IP/employee/change-count";

//staff history count
const store_staff_history = "http://$PC_IP/company/store-history";
const get_staff_history = "http://$PC_IP/company/get-history";
const staff_list_history = "http://$PC_IP/company/history-list";


//whatsapp notification
const notify =  "http://$PC_IP/company/send-notifications";


