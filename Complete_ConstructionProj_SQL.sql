CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
	role VARCHAR(50) UNIQUE NOT NULL
    email VARCHAR(100) UNIQUE NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    profile_picture_url VARCHAR(255),
    phone_number VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE
);


CREATE TABLE user_permissions (
    permission_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    module VARCHAR(50) NOT NULL,
    can_view BOOLEAN DEFAULT FALSE,
    can_create BOOLEAN DEFAULT FALSE,
    can_edit BOOLEAN DEFAULT FALSE,
    can_delete BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);


CREATE TABLE clients (
    client_id SERIAL PRIMARY KEY,
    client_name VARCHAR(100) NOT NULL,
    contact_person VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(20),
    address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TYPE project_status AS ENUM ('planning', 'active', 'on_hold', 'completed', 'cancelled');
CREATE TYPE phase_status AS ENUM ('not_started', 'in_progress', 'completed', 'delayed');


CREATE TABLE projects (
    project_id SERIAL PRIMARY KEY,
    project_name VARCHAR(100) NOT NULL,
    project_code VARCHAR(20) UNIQUE NOT NULL,
    description TEXT,
    client_id INT NOT NULL,
    project_manager_id INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    budget DECIMAL(15,2) NOT NULL,
    status project_status DEFAULT 'planning',
    progress_percentage DECIMAL(5,2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (client_id) REFERENCES clients(client_id),
    FOREIGN KEY (project_manager_id) REFERENCES users(id)
);


CREATE TABLE project_phases (
    phase_id SERIAL PRIMARY KEY,
    project_id INT NOT NULL,
    phase_name VARCHAR(100) NOT NULL,
    phase_order INT NOT NULL,
    start_date DATE,
    end_date DATE,
    status phase_status DEFAULT 'not_started',
    progress_percentage DECIMAL(5,2) DEFAULT 0.00,
    FOREIGN KEY (project_id) REFERENCES projects(project_id) ON DELETE CASCADE
);


CREATE TYPE work_type_enum AS ENUM (
  'concrete', 'steel', 'electrical', 'plumbing', 'masonry', 'finishing', 'other'
);

CREATE TABLE daily_logs (
    log_id SERIAL PRIMARY KEY,
    project_id INT NOT NULL,
    created_by INT NOT NULL,
    log_date DATE NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    weather_conditions VARCHAR(100),
    temperature DECIMAL(4,1),
    manpower_count INT,
    work_type work_type_enum NOT NULL,
    issues_encountered TEXT,
    resolutions TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (project_id) REFERENCES projects(project_id),
    FOREIGN KEY (created_by) REFERENCES users(id)
);


CREATE TABLE log_attachments (
    attachment_id SERIAL PRIMARY KEY,
    log_id INT NOT NULL,
    file_name VARCHAR(255) NOT NULL,
    file_path VARCHAR(255) NOT NULL,
    file_type VARCHAR(50),
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (log_id) REFERENCES daily_logs(log_id) ON DELETE CASCADE
);

CREATE TYPE meeting_type_enum AS ENUM (
  'client', 'internal', 'site_coordination', 'vendor', 'safety'
);

CREATE TYPE action_status_enum AS ENUM (
  'pending', 'in_progress', 'completed', 'delayed'
);

CREATE TABLE meetings (
    meeting_id SERIAL PRIMARY KEY,
    project_id INT,
    meeting_title VARCHAR(255) NOT NULL,
    meeting_date DATE NOT NULL,
    start_time TIME,
    end_time TIME,
    meeting_type meeting_type_enum NOT NULL,
    location VARCHAR(255),
    organizer_id INT NOT NULL,
    agenda TEXT,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (project_id) REFERENCES projects(project_id),
    FOREIGN KEY (organizer_id) REFERENCES users(user_id)
);

CREATE TABLE meeting_attendees (
    attendance_id SERIAL PRIMARY KEY,
    meeting_id INT NOT NULL,
    user_id INT NOT NULL,
    attended BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (meeting_id) REFERENCES meetings(meeting_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE action_items (
    action_id SERIAL PRIMARY KEY,
    meeting_id INT NOT NULL,
    description TEXT NOT NULL,
    assigned_to INT NOT NULL,
    due_date DATE NOT NULL,
    status action_status_enum DEFAULT 'pending',
    completion_notes TEXT,
    completed_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (meeting_id) REFERENCES meetings(meeting_id) ON DELETE CASCADE,
    FOREIGN KEY (assigned_to) REFERENCES users(id)
);


CREATE TYPE transaction_type_enum AS ENUM ('in', 'out', 'adjustment');
CREATE TYPE request_status_enum AS ENUM ('pending', 'approved', 'rejected', 'fulfilled');
CREATE TYPE urgency_enum AS ENUM ('normal', 'urgent', 'critical');

CREATE TABLE inventory_categories (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL,
    description TEXT
);

CREATE TABLE inventory_items (
    item_id SERIAL PRIMARY KEY,
    item_name VARCHAR(100) NOT NULL,
    description TEXT,
    category_id INT NOT NULL,
    unit_of_measure VARCHAR(20) NOT NULL,
    current_stock DECIMAL(10,2) DEFAULT 0,
    min_stock_level DECIMAL(10,2) DEFAULT 0,
    max_stock_level DECIMAL(10,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES inventory_categories(category_id)
);


CREATE TABLE inventory_transactions (
    transaction_id SERIAL PRIMARY KEY,
    item_id INT NOT NULL,
    project_id INT,
    transaction_type transaction_type_enum NOT NULL,
    quantity DECIMAL(10,2) NOT NULL,
    transaction_date DATE NOT NULL,
    notes TEXT,
    performed_by INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (item_id) REFERENCES inventory_items(item_id),
    FOREIGN KEY (project_id) REFERENCES projects(project_id),
    FOREIGN KEY (performed_by) REFERENCES users(id)
);

CREATE TABLE inventory_requests (
    request_id SERIAL PRIMARY KEY,
    project_id INT NOT NULL,
    requested_by INT NOT NULL,
    request_date DATE NOT NULL,
    status request_status_enum DEFAULT 'pending',
    urgency urgency_enum DEFAULT 'normal',
    approved_by INT,
    approved_date DATE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (project_id) REFERENCES projects(project_id),
    FOREIGN KEY (requested_by) REFERENCES users(user_id),
    FOREIGN KEY (approved_by) REFERENCES users(id)
);


CREATE TABLE request_items (
    request_item_id SERIAL PRIMARY KEY,
    request_id INT NOT NULL,
    item_id INT NOT NULL,
    quantity DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (request_id) REFERENCES inventory_requests(request_id) ON DELETE CASCADE,
    FOREIGN KEY (item_id) REFERENCES inventory_items(item_id)
);


CREATE TYPE po_status_enum AS ENUM ('draft', 'submitted', 'approved', 'rejected', 'completed');
CREATE TYPE invoice_status_enum AS ENUM ('draft', 'submitted', 'approved', 'rejected', 'paid');
CREATE TYPE budget_category_enum AS ENUM ('labor', 'materials', 'equipment', 'subcontractors', 'overhead');

CREATE TABLE vendors (
    vendor_id SERIAL PRIMARY KEY,
    vendor_name VARCHAR(100) NOT NULL,
    contact_person VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(20),
    address TEXT,
    tax_id VARCHAR(50),
    payment_terms VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE purchase_orders (
    po_id SERIAL PRIMARY KEY,
    po_number VARCHAR(50) UNIQUE NOT NULL,
    project_id INT NOT NULL,
    vendor_id INT NOT NULL,
    order_date DATE NOT NULL,
    expected_delivery_date DATE,
    status po_status_enum DEFAULT 'draft',
    total_amount DECIMAL(15,2) NOT NULL,
    created_by INT NOT NULL,
    approved_by INT,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (project_id) REFERENCES projects(project_id),
    FOREIGN KEY (vendor_id) REFERENCES vendors(vendor_id),
    FOREIGN KEY (created_by) REFERENCES users(user_id),
    FOREIGN KEY (approved_by) REFERENCES users(user_id)
);

CREATE TABLE po_items (
    po_item_id SERIAL PRIMARY KEY,
    po_id INT NOT NULL,
    item_description TEXT NOT NULL,
    quantity DECIMAL(10,2) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (po_id) REFERENCES purchase_orders(po_id) ON DELETE CASCADE
);


CREATE TABLE invoices (
    invoice_id SERIAL PRIMARY KEY,
    invoice_number VARCHAR(50) UNIQUE NOT NULL,
    po_id INT,
    vendor_id INT NOT NULL,
    project_id INT NOT NULL,
    invoice_date DATE NOT NULL,
    due_date DATE NOT NULL,
    total_amount DECIMAL(15,2) NOT NULL,
    status invoice_status_enum DEFAULT 'draft',
    submitted_by INT,
    approved_by INT,
    payment_date DATE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (po_id) REFERENCES purchase_orders(po_id),
    FOREIGN KEY (vendor_id) REFERENCES vendors(vendor_id),
    FOREIGN KEY (project_id) REFERENCES projects(project_id),
    FOREIGN KEY (submitted_by) REFERENCES users(id),
    FOREIGN KEY (approved_by) REFERENCES users(id)
);


CREATE TABLE budget_allocations (
    allocation_id SERIAL PRIMARY KEY,
    project_id INT NOT NULL,
    category budget_category_enum NOT NULL,
    allocated_amount DECIMAL(15,2) NOT NULL,
    spent_amount DECIMAL(15,2) DEFAULT 0,
    fiscal_year INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (project_id) REFERENCES projects(project_id) ON DELETE CASCADE
);

CREATE TYPE drawing_type_enum AS ENUM (
  'architectural', 'structural', 'mep', 'electrical', 'plumbing'
);

CREATE TYPE drawing_status_enum AS ENUM (
  'draft', 'under_review', 'approved', 'rejected'
);

CREATE TYPE qc_check_type_enum AS ENUM (
  'material_testing', 'workmanship', 'safety', 'compliance'
);

CREATE TYPE qc_status_enum AS ENUM (
  'scheduled', 'in_progress', 'completed', 'cancelled'
);

CREATE TYPE qc_result_enum AS ENUM (
  'pass', 'fail', 'conditional'
);



CREATE TABLE drawings (
    drawing_id SERIAL PRIMARY KEY,
    project_id INT NOT NULL,
    drawing_number VARCHAR(50) NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    drawing_type drawing_type_enum NOT NULL,
    revision VARCHAR(10) NOT NULL,
    issue_date DATE NOT NULL,
    status drawing_status_enum DEFAULT 'draft',
    file_path VARCHAR(255) NOT NULL,
    uploaded_by INT NOT NULL,
    approved_by INT,
    approval_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (project_id) REFERENCES projects(project_id),
    FOREIGN KEY (uploaded_by) REFERENCES users(id),
    FOREIGN KEY (approved_by) REFERENCES users(id)
);
CREATE TABLE quality_controls (
    qc_id SERIAL PRIMARY KEY,
    project_id INT NOT NULL,
    check_type qc_check_type_enum NOT NULL,
    check_date DATE NOT NULL,
    description TEXT,
    inspector_id INT NOT NULL,
    status qc_status_enum DEFAULT 'scheduled',
    result qc_result_enum DEFAULT NULL,
    sample_id VARCHAR(50),
    test_results TEXT,
    corrective_actions TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (project_id) REFERENCES projects(project_id),
    FOREIGN KEY (inspector_id) REFERENCES users(id)
);


CREATE TYPE specialty_enum AS ENUM (
  'electrical', 'plumbing', 'hvac', 'steel', 'concrete', 'finishing'
);

CREATE TYPE contract_status_enum AS ENUM (
  'draft', 'active', 'completed', 'terminated'
);

CREATE TABLE subcontractors (
    subcontractor_id SERIAL PRIMARY KEY,
    company_name VARCHAR(100) NOT NULL,
    contact_person VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(20),
    specialty specialty_enum NOT NULL,
    tax_id VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE subcontractor_contracts (
    contract_id SERIAL PRIMARY KEY,
    subcontractor_id INT NOT NULL,
    project_id INT NOT NULL,
    contract_number VARCHAR(50) UNIQUE NOT NULL,
    contract_value DECIMAL(15,2) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status contract_status_enum DEFAULT 'draft',
    scope_of_work TEXT,
    terms_and_conditions TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (subcontractor_id) REFERENCES subcontractors(subcontractor_id),
    FOREIGN KEY (project_id) REFERENCES projects(project_id)
);


CREATE TABLE subcontractor_workforce (
    workforce_id SERIAL PRIMARY KEY,
    contract_id INT NOT NULL,
    date DATE NOT NULL,
    workforce_count INT NOT NULL,
    work_description TEXT,
    progress_percentage DECIMAL(5,2),
    supervisor_name VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (contract_id) REFERENCES subcontractor_contracts(contract_id) ON DELETE CASCADE
);


CREATE TYPE availability_status_enum AS ENUM (
  'available', 'on_leave', 'sick', 'training', 'other'
);


CREATE TABLE project_team (
    project_team_id SERIAL PRIMARY KEY,
    project_id INT NOT NULL,
    user_id INT NOT NULL,
    role VARCHAR(50) NOT NULL,
    start_date DATE,
    end_date DATE,
    utilization_percentage DECIMAL(5,2) DEFAULT 100,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (project_id) REFERENCES projects(project_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT unique_project_user UNIQUE (project_id, user_id)
);


CREATE TABLE team_availability (
    availability_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    date DATE NOT NULL,
    status availability_status_enum DEFAULT 'available',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);


CREATE TYPE notification_type_enum AS ENUM (
  'info', 'warning', 'danger', 'success'
);


CREATE TABLE notifications (
    notification_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type notification_type_enum DEFAULT 'info',
    related_module VARCHAR(50),
    related_id INT,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);


CREATE TABLE system_activities (
    activity_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    activity_type VARCHAR(50) NOT NULL,
    description TEXT NOT NULL,
    module VARCHAR(50),
    record_id INT,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);




