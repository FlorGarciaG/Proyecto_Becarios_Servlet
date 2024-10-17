<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Login</title>
    </head>
    <body>
        <h1>Inicio de sesión</h1>
        <form method="post" action="${pageContext.request.contextPath}/login_servlet">
            Curp: 
            <input type="text" maxlength="18" minlength="18" name="curp" id="curp"><br>
            Password: 
            <input type="password" name="password" id="password" ><br>
            <br>

            <input type="submit" value="Iniciar Sesión">
        </form>
            <br>
        <button><a href="${pageContext.request.contextPath}/views/registro_becario.jsp" style="text-decoration: none; color: inherit;">Registrar becario</a></button>

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
