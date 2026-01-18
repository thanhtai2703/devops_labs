package com.example.noteservice.dto;

import lombok.Data;

@Data
public class NoteDTO {
    private Long id;
    private Long userId;
    private String title;
    private String content;
    private String createdAt;
    private String updatedAt;
}
