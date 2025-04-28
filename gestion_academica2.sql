-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 28-04-2025 a las 22:58:12
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `gestion_academica2`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `BloquearUsuario` (IN `correo_usuario` VARCHAR(100))   BEGIN
    DECLARE intentos_actuales INT;
    
    -- Obtener el número de intentos fallidos
    SELECT intentos INTO intentos_actuales FROM usuarios WHERE correo = correo_usuario;
    
    -- Si tiene 3 o más intentos, bloquear usuario
    IF intentos_actuales >= 3 THEN
        UPDATE usuarios SET bloqueado = TRUE WHERE correo = correo_usuario;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `RegistrarAuditoria` (IN `usuario_id` INT, IN `accion` VARCHAR(50), IN `descripcion` TEXT)   BEGIN
    INSERT INTO auditoria (usuario_id, accion, descripcion, fecha)
    VALUES (usuario_id, accion, descripcion, NOW());
END$$

--
-- Funciones
--
CREATE DEFINER=`root`@`localhost` FUNCTION `ObtenerNombreCompleto` (`id_usuario` INT) RETURNS VARCHAR(255) CHARSET utf8mb4 COLLATE utf8mb4_general_ci DETERMINISTIC BEGIN
    DECLARE nombre_completo VARCHAR(255);
    
    SELECT CONCAT(nombre, ' ', apellido) INTO nombre_completo FROM usuarios WHERE id = id_usuario;
    
    RETURN nombre_completo;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `areasinstitucion`
--

CREATE TABLE `areasinstitucion` (
  `id_area` int(11) NOT NULL,
  `nombre_area` varchar(100) DEFAULT NULL,
  `descripcion` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `auditoria`
--

CREATE TABLE `auditoria` (
  `id_auditoria` int(11) NOT NULL,
  `usuario_afectado` int(11) DEFAULT NULL,
  `descripcion` text DEFAULT NULL,
  `fecha_operacion` timestamp NOT NULL DEFAULT current_timestamp(),
  `usuario_realiza_operacion` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cursos`
--

CREATE TABLE `cursos` (
  `id_curso` int(11) NOT NULL,
  `nombre_curso` varchar(100) DEFAULT NULL,
  `id_programa` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `docentecurso`
--

CREATE TABLE `docentecurso` (
  `id_docente_curso` int(11) NOT NULL,
  `id_usuario` int(11) DEFAULT NULL,
  `id_curso` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `equipostecnologicos`
--

CREATE TABLE `equipostecnologicos` (
  `id_equipo` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `tipo` varchar(50) DEFAULT NULL,
  `estado` enum('activo','inactivo') DEFAULT 'activo'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `estudiantesactivos`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `estudiantesactivos` (
`id_usuario` int(11)
,`nombre` varchar(50)
,`apellido` varchar(50)
,`documento_identidad` varchar(20)
,`tipo_usuario` enum('estudiante','docente','administrativo')
,`email` varchar(100)
,`telefono` varchar(20)
,`direccion` varchar(255)
,`estado` enum('activo','bloqueado')
,`fecha_registro` timestamp
);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `eventos`
--

CREATE TABLE `eventos` (
  `id_evento` int(11) NOT NULL,
  `titulo_evento` varchar(100) DEFAULT NULL,
  `descripcion_evento` text DEFAULT NULL,
  `fecha_evento` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `lugar_evento` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `inscripciones`
--

CREATE TABLE `inscripciones` (
  `id_inscripcion` int(11) NOT NULL,
  `id_usuario` int(11) DEFAULT NULL,
  `id_curso` int(11) DEFAULT NULL,
  `fecha_inscripcion` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `notas`
--

CREATE TABLE `notas` (
  `id_nota` int(11) NOT NULL,
  `id_usuario` int(11) DEFAULT NULL,
  `id_curso` int(11) DEFAULT NULL,
  `nota` decimal(5,2) DEFAULT NULL,
  `periodo` enum('1','2','3','4') DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `personaladministrativo`
--

CREATE TABLE `personaladministrativo` (
  `id_personal` int(11) NOT NULL,
  `id_usuario` int(11) DEFAULT NULL,
  `cargo` varchar(100) DEFAULT NULL,
  `dependencia` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `programas`
--

CREATE TABLE `programas` (
  `id_programa` int(11) NOT NULL,
  `nombre_programa` varchar(100) DEFAULT NULL,
  `descripcion` text DEFAULT NULL,
  `nivel` enum('pregrado','posgrado') DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuarios`
--

CREATE TABLE `usuarios` (
  `id_usuario` int(11) NOT NULL,
  `nombre` varchar(50) DEFAULT NULL,
  `apellido` varchar(50) DEFAULT NULL,
  `documento_identidad` varchar(20) DEFAULT NULL,
  `tipo_usuario` enum('estudiante','docente','administrativo') DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `telefono` varchar(20) DEFAULT NULL,
  `direccion` varchar(255) DEFAULT NULL,
  `estado` enum('activo','bloqueado') DEFAULT NULL,
  `fecha_registro` timestamp NOT NULL DEFAULT current_timestamp(),
  `correo` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Disparadores `usuarios`
--
DELIMITER $$
CREATE TRIGGER `AuditarCambioUsuario` AFTER UPDATE ON `usuarios` FOR EACH ROW BEGIN
    INSERT INTO auditoria (usuario_id, accion, descripcion, fecha)
    VALUES (NEW.id_usuario, 'Actualización', CONCAT('Cambio de usuario: ', OLD.nombre, ' a ', NEW.nombre), NOW());
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `AuditarEliminacionUsuario` AFTER DELETE ON `usuarios` FOR EACH ROW BEGIN
    INSERT INTO auditoria (usuario_id, accion, descripcion, fecha)
    VALUES (OLD.id_usuario, 'Eliminación', CONCAT('Usuario eliminado: ', OLD.nombre), NOW());
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `AuditarRegistroUsuario` AFTER INSERT ON `usuarios` FOR EACH ROW BEGIN
    INSERT INTO auditoria (usuario_id, accion, descripcion, fecha)
    VALUES (NEW.id_usuario, 'Registro', CONCAT('Usuario registrado: ', NEW.nombre), NOW());
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `usuariosactivos`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `usuariosactivos` (
`id_usuario` int(11)
,`nombre` varchar(50)
,`apellido` varchar(50)
,`correo` varchar(100)
,`estado` enum('activo','bloqueado')
);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuariosbloqueados`
--

CREATE TABLE `usuariosbloqueados` (
  `id_bloqueo` int(11) NOT NULL,
  `id_usuario` int(11) DEFAULT NULL,
  `razon_bloqueo` text DEFAULT NULL,
  `fecha_bloqueo` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vistainscripciones`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vistainscripciones` (
`id_inscripcion` int(11)
,`nombre` varchar(50)
,`apellido` varchar(50)
,`fecha_inscripcion` timestamp
);

-- --------------------------------------------------------

--
-- Estructura para la vista `estudiantesactivos`
--
DROP TABLE IF EXISTS `estudiantesactivos`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `estudiantesactivos`  AS SELECT `usuarios`.`id_usuario` AS `id_usuario`, `usuarios`.`nombre` AS `nombre`, `usuarios`.`apellido` AS `apellido`, `usuarios`.`documento_identidad` AS `documento_identidad`, `usuarios`.`tipo_usuario` AS `tipo_usuario`, `usuarios`.`email` AS `email`, `usuarios`.`telefono` AS `telefono`, `usuarios`.`direccion` AS `direccion`, `usuarios`.`estado` AS `estado`, `usuarios`.`fecha_registro` AS `fecha_registro` FROM `usuarios` WHERE `usuarios`.`estado` = 'activo' ;

-- --------------------------------------------------------

--
-- Estructura para la vista `usuariosactivos`
--
DROP TABLE IF EXISTS `usuariosactivos`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `usuariosactivos`  AS SELECT `usuarios`.`id_usuario` AS `id_usuario`, `usuarios`.`nombre` AS `nombre`, `usuarios`.`apellido` AS `apellido`, `usuarios`.`correo` AS `correo`, `usuarios`.`estado` AS `estado` FROM `usuarios` WHERE `usuarios`.`estado` = 'activo' ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vistainscripciones`
--
DROP TABLE IF EXISTS `vistainscripciones`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vistainscripciones`  AS SELECT `i`.`id_inscripcion` AS `id_inscripcion`, `e`.`nombre` AS `nombre`, `e`.`apellido` AS `apellido`, `i`.`fecha_inscripcion` AS `fecha_inscripcion` FROM (`inscripciones` `i` join `usuarios` `e` on(`i`.`id_usuario` = `e`.`id_usuario`)) ;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `areasinstitucion`
--
ALTER TABLE `areasinstitucion`
  ADD PRIMARY KEY (`id_area`);

--
-- Indices de la tabla `auditoria`
--
ALTER TABLE `auditoria`
  ADD PRIMARY KEY (`id_auditoria`),
  ADD KEY `usuario_afectado` (`usuario_afectado`),
  ADD KEY `usuario_realiza_operacion` (`usuario_realiza_operacion`);

--
-- Indices de la tabla `cursos`
--
ALTER TABLE `cursos`
  ADD PRIMARY KEY (`id_curso`),
  ADD KEY `id_programa` (`id_programa`);

--
-- Indices de la tabla `docentecurso`
--
ALTER TABLE `docentecurso`
  ADD PRIMARY KEY (`id_docente_curso`),
  ADD KEY `id_usuario` (`id_usuario`),
  ADD KEY `id_curso` (`id_curso`);

--
-- Indices de la tabla `equipostecnologicos`
--
ALTER TABLE `equipostecnologicos`
  ADD PRIMARY KEY (`id_equipo`);

--
-- Indices de la tabla `eventos`
--
ALTER TABLE `eventos`
  ADD PRIMARY KEY (`id_evento`);

--
-- Indices de la tabla `inscripciones`
--
ALTER TABLE `inscripciones`
  ADD PRIMARY KEY (`id_inscripcion`),
  ADD KEY `id_usuario` (`id_usuario`),
  ADD KEY `id_curso` (`id_curso`);

--
-- Indices de la tabla `notas`
--
ALTER TABLE `notas`
  ADD PRIMARY KEY (`id_nota`),
  ADD KEY `id_usuario` (`id_usuario`),
  ADD KEY `id_curso` (`id_curso`);

--
-- Indices de la tabla `personaladministrativo`
--
ALTER TABLE `personaladministrativo`
  ADD PRIMARY KEY (`id_personal`),
  ADD KEY `id_usuario` (`id_usuario`);

--
-- Indices de la tabla `programas`
--
ALTER TABLE `programas`
  ADD PRIMARY KEY (`id_programa`);

--
-- Indices de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  ADD PRIMARY KEY (`id_usuario`),
  ADD UNIQUE KEY `correo` (`correo`),
  ADD UNIQUE KEY `documento_identidad` (`documento_identidad`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indices de la tabla `usuariosbloqueados`
--
ALTER TABLE `usuariosbloqueados`
  ADD PRIMARY KEY (`id_bloqueo`),
  ADD KEY `id_usuario` (`id_usuario`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `areasinstitucion`
--
ALTER TABLE `areasinstitucion`
  MODIFY `id_area` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `auditoria`
--
ALTER TABLE `auditoria`
  MODIFY `id_auditoria` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `cursos`
--
ALTER TABLE `cursos`
  MODIFY `id_curso` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `docentecurso`
--
ALTER TABLE `docentecurso`
  MODIFY `id_docente_curso` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `equipostecnologicos`
--
ALTER TABLE `equipostecnologicos`
  MODIFY `id_equipo` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `eventos`
--
ALTER TABLE `eventos`
  MODIFY `id_evento` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `inscripciones`
--
ALTER TABLE `inscripciones`
  MODIFY `id_inscripcion` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `notas`
--
ALTER TABLE `notas`
  MODIFY `id_nota` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `personaladministrativo`
--
ALTER TABLE `personaladministrativo`
  MODIFY `id_personal` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `programas`
--
ALTER TABLE `programas`
  MODIFY `id_programa` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  MODIFY `id_usuario` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `usuariosbloqueados`
--
ALTER TABLE `usuariosbloqueados`
  MODIFY `id_bloqueo` int(11) NOT NULL AUTO_INCREMENT;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `auditoria`
--
ALTER TABLE `auditoria`
  ADD CONSTRAINT `auditoria_ibfk_1` FOREIGN KEY (`usuario_afectado`) REFERENCES `usuarios` (`id_usuario`),
  ADD CONSTRAINT `auditoria_ibfk_2` FOREIGN KEY (`usuario_realiza_operacion`) REFERENCES `usuarios` (`id_usuario`);

--
-- Filtros para la tabla `cursos`
--
ALTER TABLE `cursos`
  ADD CONSTRAINT `cursos_ibfk_1` FOREIGN KEY (`id_programa`) REFERENCES `programas` (`id_programa`);

--
-- Filtros para la tabla `docentecurso`
--
ALTER TABLE `docentecurso`
  ADD CONSTRAINT `docentecurso_ibfk_1` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`),
  ADD CONSTRAINT `docentecurso_ibfk_2` FOREIGN KEY (`id_curso`) REFERENCES `cursos` (`id_curso`);

--
-- Filtros para la tabla `inscripciones`
--
ALTER TABLE `inscripciones`
  ADD CONSTRAINT `inscripciones_ibfk_1` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`),
  ADD CONSTRAINT `inscripciones_ibfk_2` FOREIGN KEY (`id_curso`) REFERENCES `cursos` (`id_curso`);

--
-- Filtros para la tabla `notas`
--
ALTER TABLE `notas`
  ADD CONSTRAINT `notas_ibfk_1` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`),
  ADD CONSTRAINT `notas_ibfk_2` FOREIGN KEY (`id_curso`) REFERENCES `cursos` (`id_curso`);

--
-- Filtros para la tabla `personaladministrativo`
--
ALTER TABLE `personaladministrativo`
  ADD CONSTRAINT `personaladministrativo_ibfk_1` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`);

--
-- Filtros para la tabla `usuariosbloqueados`
--
ALTER TABLE `usuariosbloqueados`
  ADD CONSTRAINT `usuariosbloqueados_ibfk_1` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
