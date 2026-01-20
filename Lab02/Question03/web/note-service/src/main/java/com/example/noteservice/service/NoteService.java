package com.example.noteservice.service;

import com.example.noteservice.dto.CreateNoteRequest;
import com.example.noteservice.dto.NoteDTO;
import com.example.noteservice.dto.UpdateNoteRequest;
import com.example.noteservice.model.Note;
import com.example.noteservice.repository.NoteRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class NoteService {

    @Autowired
    private NoteRepository noteRepository;

    public NoteDTO createNote(CreateNoteRequest request) {
        Note note = new Note();
        note.setUserId(request.getUserId());
        note.setTitle(request.getTitle());
        note.setContent(request.getContent());
        
        Note savedNote = noteRepository.save(note);
        return convertToDTO(savedNote);
    }

    public List<NoteDTO> getAllNotes() {
        return noteRepository.findAll().stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public List<NoteDTO> getNotesByUserId(Long userId) {
        return noteRepository.findByUserId(userId).stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public NoteDTO getNoteById(Long id) {
        Note note = noteRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Note not found with id: " + id));
        return convertToDTO(note);
    }

    public NoteDTO updateNote(Long id, UpdateNoteRequest request) {
        Note note = noteRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Note not found with id: " + id));
        
        note.setTitle(request.getTitle());
        note.setContent(request.getContent());
        
        Note updatedNote = noteRepository.save(note);
        return convertToDTO(updatedNote);
    }

    public void deleteNote(Long id) {
        if (!noteRepository.existsById(id)) {
            throw new RuntimeException("Note not found with id: " + id);
        }
        noteRepository.deleteById(id);
    }

    private NoteDTO convertToDTO(Note note) {
        NoteDTO dto = new NoteDTO();
        dto.setId(note.getId());
        dto.setUserId(note.getUserId());
        dto.setTitle(note.getTitle());
        dto.setContent(note.getContent());
        dto.setCreatedAt(note.getCreatedAt() != null ? note.getCreatedAt().toString() : null);
        dto.setUpdatedAt(note.getUpdatedAt() != null ? note.getUpdatedAt().toString() : null);
        return dto;
    }
}
