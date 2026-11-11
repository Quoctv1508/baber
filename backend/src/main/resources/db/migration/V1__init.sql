
CREATE TABLE users (
    id  BIGINT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(15) NOT NULL,
    email VARCHAR(150) NOT NULL,
    password_hash VARCHAR(225) NOT NULL,
    role ENUM('CUSTOMER', 'BABER', 'ADMIN') NOT NULL DEFAULT 'CUSTOMER',
    avatar_url VARCHAR(500) NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_users_phone (phone),
    UNIQUE KEY uk_users_email (email)
) ENGINE = InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE branches(
    id  BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    address VARCHAR(255) NOT NULL,
    phone VARCHAR(15) NULL,
    open_time TIME NOT NULL DEFAULT '08:00:00',
    close_time TIME NOT NULL DEFAULT '21:00:00',
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
)ENGINE = InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE babers (
    id                  BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id             BIGINT NOT NULL,
    branch_id           BIGINT NOT NULL,
    bio                 TEXT NULL,
    experience_years     TINYINT UNSIGNED NOT NULL DEFAULT 0,
    rating_avg          DECIMAL(3,2) NOT NULL DEFAULT 0.00,
    rating_count        INT NOT NULL DEFAULT 0,
    is_active        BOOLEAN NOT NULL DEFAULT TRUE,
    created_at             DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_babers_user (user_id),
    CONSTRAINT fk_babers_user FOREIGN KEY(user_id) REFERENCES users(id),
    CONSTRAINT fk_babers_branch FOREIGN KEY(branch_id) REFERENCES branches(id)
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE service_categories(
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    sort_order INT NOT NULL DEFAULT 0
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE services(
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    categorie_id BIGINT NULL,
    name VARCHAR(150) NOT NULL,
    description TEXT NULL,
    price DECIMAL(12, 0) NOT NULL,
    image_url VARCHAR(500) NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_service_category FOREIGN KEY (categorie_id) REFERENCES service_categories(id),
    CONSTRAINT chk_services_price CHECK(price >=0),
    CONSTRAINT chk_services_duration CHECK (duration_minutes > 0)
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE baber_services(
    baber_id BIGINT NOT NULL,
    service_id BIGINT NOT NULL,
    custom_price DECIMAL(12,0) NULL,
    PRIMARY KEY (barber_id, service_id),
    CONSTRAINT fk_bs_barber  FOREIGN KEY (barber_id)  REFERENCES barbers(id)  ON DELETE CASCADE,
    CONSTRAINT fk_bs_service FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE CASCADE

)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE working_hours (
  id          BIGINT AUTO_INCREMENT PRIMARY KEY,
  barber_id   BIGINT NOT NULL,
  day_of_week TINYINT NOT NULL,
  start_time  TIME NOT NULL,
  end_time    TIME NOT NULL,
  CONSTRAINT fk_wh_barber FOREIGN KEY (barber_id) REFERENCES barbers(id) ON DELETE CASCADE,
  CONSTRAINT chk_wh_day  CHECK (day_of_week BETWEEN 1 AND 7),
  CONSTRAINT chk_wh_time CHECK (end_time > start_time),
  KEY idx_wh_barber_day (barber_id, day_of_week)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;



CREATE TABLE appointments (
  id            BIGINT AUTO_INCREMENT PRIMARY KEY,
  code          VARCHAR(20) NOT NULL,
  customer_id   BIGINT NOT NULL,
  barber_id     BIGINT NOT NULL,
  branch_id     BIGINT NOT NULL,
  start_at      DATETIME NOT NULL,
  end_at        DATETIME NOT NULL,
  status        ENUM('PENDING','CONFIRMED','IN_PROGRESS','COMPLETED','CANCELLED','NO_SHOW')
                NOT NULL DEFAULT 'PENDING',
  subtotal      DECIMAL(12,0) NOT NULL,
  discount      DECIMAL(12,0) NOT NULL DEFAULT 0,
  total_price   DECIMAL(12,0) NOT NULL,
  note          VARCHAR(500) NULL,
  cancel_reason VARCHAR(255) NULL,
  cancelled_at  DATETIME NULL,
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  version       INT NOT NULL DEFAULT 0,
  UNIQUE KEY uk_appt_code (code),
  CONSTRAINT fk_appt_customer FOREIGN KEY (customer_id) REFERENCES users(id),
  CONSTRAINT fk_appt_barber   FOREIGN KEY (barber_id)   REFERENCES barbers(id),
  CONSTRAINT fk_appt_branch   FOREIGN KEY (branch_id)   REFERENCES branches(id),
  CONSTRAINT chk_appt_time    CHECK (end_at > start_at),
  CONSTRAINT chk_appt_total   CHECK (total_price >= 0),
  KEY idx_appt_barber_time   (barber_id, start_at, end_at),
  KEY idx_appt_customer_time (customer_id, start_at),
  KEY idx_appt_status        (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE appointment_services (
  appointment_id   BIGINT NOT NULL,
  service_id       BIGINT NOT NULL,
  service_name     VARCHAR(150) NOT NULL,
  price            DECIMAL(12,0) NOT NULL,
  duration_minutes SMALLINT UNSIGNED NOT NULL,
  PRIMARY KEY (appointment_id, service_id),
  CONSTRAINT fk_as_appt    FOREIGN KEY (appointment_id) REFERENCES appointments(id) ON DELETE CASCADE,
  CONSTRAINT fk_as_service FOREIGN KEY (service_id)     REFERENCES services(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
