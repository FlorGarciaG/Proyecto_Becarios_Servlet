<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Registro becario</title>
    </head>
    <body>
        <h1>Alta becario</h1>
        <form action="${pageContext.request.contextPath}/becario_servlet" method="POST">
            CURP:
            <input type="text" id="curp" name="curp" maxlength="18" minlength="18" required><br>

            Nombre:
            <input type="text" id="nombre" name="nombre" required><br>

            Apellido Paterno:
            <input type="text" id="apellidoP" name="apellidoP" required><br>

            Apellido Materno:
            <input type="text" id="apellidoM" name="apellidoM" required><br>

            Género:
            <input type="radio" id="masculino" name="genero" value="M" required>
            <label for="masculino">Masculino</label>
            <input type="radio" id="femenino" name="genero" value="F" required>
            <label for="femenino">Femenino</label><br>

            Password:
            <input type="password" id="password" name="password" required><br>

            <input type="submit" name="accion" value="Registrar">
        </form>
        <%
            String mensaje = (String) request.getAttribute("mensaje");
            if (mensaje != null) {
        %>
        <script>
            alert("<%= mensaje%>");
        </script>
        <%
            }
        %>
    </body>
</html>
