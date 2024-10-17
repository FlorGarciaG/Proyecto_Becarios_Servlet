/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package Controller;

import Configuration.ConnectionBD;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import org.mindrot.jbcrypt.BCrypt;

/**
 *
 * @author florc
 */
@WebServlet(name = "login_servlet", urlPatterns = {"/login_servlet"})
public class login_servlet extends HttpServlet {

    Connection conn;
    PreparedStatement ps;
    Statement statement;
    ResultSet rs;

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try ( PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet login_servlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet login_servlet at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false); // No crear sesión

        if (session != null) {
            session.invalidate(); // Invalidar la sesión si existe
        }

        // Eliminar la cookie
        Cookie[] cookies = request.getCookies();
        if (cookies != null) {
            for (Cookie cookie : cookies) {
                if ("curp".equals(cookie.getName())) {
                    cookie.setMaxAge(0); // Eliminar la cookie
                    cookie.setPath("/"); // Asegurar que se elimine en todo el contexto
                    response.addCookie(cookie); // Agregar la cookie eliminada a la respuesta
                    break;
                }
            }
        }

        // Redirigir al login
        response.sendRedirect(request.getContextPath() + "/views/login.jsp");
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        //Obtener la matricula y password del formulario
        String curp = request.getParameter("curp");
        String password = request.getParameter("password");

        //Operaciones con la base de datos
        try {
            ConnectionBD conexion = new ConnectionBD();
            conn = conexion.getConnectionBD();
            String sql = "SELECT password FROM becario WHERE curp = ?";
            ps = conn.prepareStatement(sql);
            ps.setString(1, curp);

            rs = ps.executeQuery();

            if (rs.next()) {
                String hashPassword = rs.getString("password");

                HttpSession session = request.getSession();
                session.setMaxInactiveInterval(120); // 2 minutos (120 segundos)
                session.setAttribute("curp", curp);
                if (BCrypt.checkpw(password, hashPassword)) {
                    //Cuando la contraseña es correcta creara la cookie
                    Cookie cookie = new Cookie("curp", curp);

                    cookie.setMaxAge(60 * 15); // vida de 15 min
                    //Establecer la ruta
                    cookie.setPath("/");
                    // Agregar la cookie a la respuesta
                    response.addCookie(cookie);
                    response.sendRedirect(request.getContextPath() + "/views/bienvenida.jsp");
                } else {
                    request.getRequestDispatcher("/views/error.jsp").forward(request, response);
                }
            } else {
                request.getRequestDispatcher("/views/error.jsp").forward(request, response);
            }
            rs.close();
            ps.close();
            conn.close();
        } catch (Exception e) {
            System.out.println("Error " + e);
        }
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
