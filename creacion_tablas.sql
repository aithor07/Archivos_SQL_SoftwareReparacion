-- Se borran en orden inverso para no romper las restricciones de FK
-- Permite el testeo de la BBDD
DROP TABLE IF EXISTS Pedido_Linea_Repuesto;
DROP TABLE IF EXISTS PedidoRepuestos;
DROP TABLE IF EXISTS Proveedor;
DROP TABLE IF EXISTS Repuesto;
DROP TABLE IF EXISTS Factura;
DROP TABLE IF EXISTS Presupuesto;
DROP TABLE IF EXISTS Diagnostico;
DROP TABLE IF EXISTS Reparacion;
DROP TABLE IF EXISTS Equipo;
DROP TABLE IF EXISTS Tecnico;
DROP TABLE IF EXISTS Cliente;
DROP TABLE IF EXISTS Empresa_Configuracion;


-- TABLA MAESTRA: Configuración de los diferentes talleres (clientes del software)
CREATE TABLE Empresa_Configuracion (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombreComercial VARCHAR(150) NOT NULL,
    razonSocial VARCHAR(150) NOT NULL,
    nif_cif VARCHAR(20) NOT NULL,
    num_licencia VARCHAR(100),
    tipo_impuesto VARCHAR(10) DEFAULT 'IGIC',
    porcentaje_impuesto DECIMAL(5,2) DEFAULT 21.00
);

CREATE TABLE Cliente (
    id INT AUTO_INCREMENT PRIMARY KEY,
    empresa_id INT NOT NULL,
    nombreCompleto VARCHAR(150) NOT NULL,
    dni VARCHAR(20),
    telefono VARCHAR(20),
    correo VARCHAR(100),
    FOREIGN KEY (empresa_id) REFERENCES Empresa_Configuracion(id) ON DELETE CASCADE
);

CREATE TABLE Tecnico (
    id INT AUTO_INCREMENT PRIMARY KEY,
    empresa_id INT NOT NULL,
    nombreCompleto VARCHAR(150) NOT NULL,
    telefono VARCHAR(20),
    departamento ENUM('HARDWARE','SOFTWARE','MOVILES','ELECTRONICA') NOT NULL,
    FOREIGN KEY (empresa_id) REFERENCES Empresa_Configuracion(id) ON DELETE CASCADE
);

CREATE TABLE Equipo (
    id INT AUTO_INCREMENT PRIMARY KEY,
    empresa_id INT NOT NULL,
    clientePropietario_id INT NOT NULL,
    tipo VARCHAR(50) NOT NULL,
    marca VARCHAR(50),
    modelo VARCHAR(50),
    numeroSerie VARCHAR(100),
    descripcionInicial TEXT,
    FOREIGN KEY (empresa_id) REFERENCES Empresa_Configuracion(id) ON DELETE CASCADE,
    FOREIGN KEY (clientePropietario_id) REFERENCES Cliente(id) ON DELETE RESTRICT
);

CREATE TABLE Reparacion (
    id INT AUTO_INCREMENT PRIMARY KEY,
    empresa_id INT NOT NULL,
    equipo_id INT NOT NULL,
    tecnicoRecepcion_id INT,
    tecnicoAsignado_id INT,
    prioridad ENUM('BAJA','MEDIA','ALTA','URGENTE') DEFAULT 'MEDIA',
    fechaIngreso DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fechaFinPrevista DATETIME,
    fechaFinReal DATETIME,
    estado ENUM('REGISTRADA','EN_DIAGNOSTICO','PRESUPUESTADA','PENDIENTE_REPUESTOS','EN_REPARACION','FINALIZADA','ENTREGADA','CANCELADA') DEFAULT 'REGISTRADA',
    FOREIGN KEY (empresa_id) REFERENCES Empresa_Configuracion(id) ON DELETE CASCADE,
    FOREIGN KEY (equipo_id) REFERENCES Equipo(id) ON DELETE RESTRICT,
    FOREIGN KEY (tecnicoRecepcion_id) REFERENCES Tecnico(id) ON DELETE SET NULL,
    FOREIGN KEY (tecnicoAsignado_id) REFERENCES Tecnico(id) ON DELETE SET NULL
);

CREATE TABLE Diagnostico (
    id INT AUTO_INCREMENT PRIMARY KEY,
    reparacion_id INT NOT NULL,
    tecnicoDiagnostico_id INT,
    fecha DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    descripcionProblema TEXT NOT NULL,
    solucionPropuesta TEXT,
    requiereRepuestos TINYINT(1) DEFAULT 0,
    FOREIGN KEY (reparacion_id) REFERENCES Reparacion(id) ON DELETE CASCADE,
    FOREIGN KEY (tecnicoDiagnostico_id) REFERENCES Tecnico(id) ON DELETE SET NULL
);

CREATE TABLE Presupuesto (
    id INT AUTO_INCREMENT PRIMARY KEY,
    reparacion_id INT NOT NULL,
    fechaCreacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    costeRepuestos DECIMAL(10,2) DEFAULT 0.00,
    costeManoObra DECIMAL(10,2) DEFAULT 0.00,
    impuesto DECIMAL(10,2) DEFAULT 0.00,
    total DECIMAL(10,2) DEFAULT 0.00,
    estado ENUM('PENDIENTE','ACEPTADO','RECHAZADO','ACEPTADO_PARCIAL') DEFAULT 'PENDIENTE',
    FOREIGN KEY (reparacion_id) REFERENCES Reparacion(id) ON DELETE CASCADE
);

CREATE TABLE Factura (
    id INT AUTO_INCREMENT PRIMARY KEY,
    empresa_id INT NOT NULL,
    reparacion_id INT NOT NULL,
    fechaEmision DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    baseImponible DECIMAL(10,2) NOT NULL,
    iva DECIMAL(10,2) NOT NULL,
    total DECIMAL(10,2) NOT NULL,
    estado ENUM('PENDIENTE_DE_PAGO','PAGADA','ANULADA') DEFAULT 'PENDIENTE_DE_PAGO',
    FOREIGN KEY (empresa_id) REFERENCES Empresa_Configuracion(id) ON DELETE CASCADE,
    FOREIGN KEY (reparacion_id) REFERENCES Reparacion(id) ON DELETE RESTRICT
);

CREATE TABLE Repuesto (
    id INT AUTO_INCREMENT PRIMARY KEY,
    empresa_id INT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    coste DECIMAL(10,2) NOT NULL,
    stock INT DEFAULT 0,
    FOREIGN KEY (empresa_id) REFERENCES Empresa_Configuracion(id) ON DELETE CASCADE
);

CREATE TABLE Proveedor (
    id INT AUTO_INCREMENT PRIMARY KEY,
    empresa_id INT NOT NULL,
    nombre VARCHAR(150) NOT NULL,
    telefono VARCHAR(20),
    correo VARCHAR(100),
    FOREIGN KEY (empresa_id) REFERENCES Empresa_Configuracion(id) ON DELETE CASCADE
);

CREATE TABLE PedidoRepuestos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    empresa_id INT NOT NULL,
    proveedor_id INT NOT NULL,
    fechaPedido DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fechaRecepcion DATETIME,
    estado VARCHAR(50) DEFAULT 'EN_PROCESO',
    FOREIGN KEY (empresa_id) REFERENCES Empresa_Configuracion(id) ON DELETE CASCADE,
    FOREIGN KEY (proveedor_id) REFERENCES Proveedor(id) ON DELETE RESTRICT
);

-- TABLA INTERMEDIA (Muchos a Muchos: Pedido <-> Repuestos)
CREATE TABLE Pedido_Linea_Repuesto (
    pedido_id INT NOT NULL,
    repuesto_id INT NOT NULL,
    cantidad INT NOT NULL DEFAULT 1,
    PRIMARY KEY (pedido_id, repuesto_id),
    FOREIGN KEY (pedido_id) REFERENCES PedidoRepuestos(id) ON DELETE CASCADE,
    FOREIGN KEY (repuesto_id) REFERENCES Repuesto(id) ON DELETE RESTRICT
);
