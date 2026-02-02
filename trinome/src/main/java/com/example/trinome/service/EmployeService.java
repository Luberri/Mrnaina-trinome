package com.example.trinome.service;

import com.example.trinome.model.Employe;
import com.example.trinome.repository.EmployeRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class EmployeService {
    
    @Autowired
    private EmployeRepository employeRepository;
    
    // Create
    public Employe saveEmploye(Employe employe) {
        return employeRepository.save(employe);
    }
    
    // Read all
    public List<Employe> getAllEmployes() {
        return employeRepository.findAll();
    }
    
    // Read by ID
    public Optional<Employe> getEmployeById(Long id) {
        return employeRepository.findById(id);
    }
    
    // Update
    public Employe updateEmploye(Long id, Employe employe) {
        if (employeRepository.existsById(id)) {
            employe.setId(id);
            return employeRepository.save(employe);
        }
        return null;
    }
    
    // Delete
    public void deleteEmploye(Long id) {
        employeRepository.deleteById(id);
    }
}