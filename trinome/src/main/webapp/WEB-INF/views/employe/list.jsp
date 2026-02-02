<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title><c:if test="${employe.id == null}">Ajouter</c:if><c:if test="${employe.id != null}">Modifier</c:if> un Employé</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
            background-color: #f5f5f5;
        }
        .container {
            background-color: white;
            padding: 20px;
            border-radius: 5px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
            max-width: 500px;
            margin: 0 auto;
        }
        h1 {
            color: #333;
            border-bottom: 2px solid #007bff;
            padding-bottom: 10px;
        }
        .form-group {
            margin-bottom: 15px;
        }
        label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
            color: #333;
        }
        input[type="text"],
        input[type="email"] {
            width: 100%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 4px;
            box-sizing: border-box;
            font-size: 14px;
        }
        input[type="text"]:focus,
        input[type="email"]:focus {
            outline: none;
            border-color: #007bff;
            box-shadow: 0 0 5px rgba(0, 123, 255, 0.25);
        }
        .btn {
            padding: 10px 20px;
            margin: 10px 5px 10px 0;
            text-decoration: none;
            border-radius: 4px;
            font-weight: bold;
            cursor: pointer;
            border: none;
        }
        .btn-save {
            background-color: #28a745;
            color: white;
        }
        .btn-cancel {
            background-color: #6c757d;
            color: white;
        }
        .btn:hover {
            opacity: 0.8;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>
            <c:if test="${employe.id == null}">Ajouter un Employé</c:if>
            <c:if test="${employe.id != null}">Modifier l'Employé</c:if>
        </h1>
        
        <form method="post" action="<c:if test="${employe.id == null}">/employe/save</c:if><c:if test="${employe.id != null}">/employe/update/${employe.id}</c:if>">
            
            <div class="form-group">
                <label for="nom">Nom:</label>
                <input type="text" id="nom" name="nom" value="${employe.nom}" required>
            </div>
            
            <div class="form-group">
                <label for="email">Email:</label>
                <input type="email" id="email" name="email" value="${employe.email}" required>
            </div>
            
            <button type="submit" class="btn btn-save">
                <c:if test="${employe.id == null}">Créer</c:if>
                <c:if test="${employe.id != null}">Mettre à jour</c:if>
            </button>
            <a href="/employe/list" class="btn btn-cancel">Annuler</a>
        </form>
    </div>
</body>
</html>