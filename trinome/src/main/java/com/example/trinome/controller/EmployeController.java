package com.example.trinome.controller;

import com.example.trinome.model.Employe;
import com.example.trinome.service.EmployeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import java.util.Optional;

@Controller
@RequestMapping("/employe")
public class EmployeController {
    
    @Autowired
    private EmployeService employeService;
    
    // List all employees
    @GetMapping("/list")
    public String listEmployes(Model model) {
        model.addAttribute("employes", employeService.getAllEmployes());
        return "employe/list";
    }
    
    // Show add form
    @GetMapping("/add")
    public String showAddForm(Model model) {
        model.addAttribute("employe", new Employe());
        return "employe/form";
    }
    
    // Save new employee
    @PostMapping("/save")
    public String saveEmploye(@ModelAttribute Employe employe) {
        employeService.saveEmploye(employe);
        return "redirect:/employe/list";
    }
    
    // Show edit form
    @GetMapping("/edit/{id}")
    public String showEditForm(@PathVariable Long id, Model model) {
        Optional<Employe> employe = employeService.getEmployeById(id);
        if (employe.isPresent()) {
            model.addAttribute("employe", employe.get());
            return "employe/form";
        }
        return "redirect:/employe/list";
    }
    
    // Update employee
    @PostMapping("/update/{id}")
    public String updateEmploye(@PathVariable Long id, @ModelAttribute Employe employe) {
        employeService.updateEmploye(id, employe);
        return "redirect:/employe/list";
    }
    
    // Delete employee
    @GetMapping("/delete/{id}")
    public String deleteEmploye(@PathVariable Long id) {
        employeService.deleteEmploye(id);
        return "redirect:/employe/list";
    }
}