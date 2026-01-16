import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class InputImage extends StatefulWidget {
  final String? label;
  final bool multiple;
  final void Function(File?)? onChanged; // para single (mantido para compatibilidade)
  final void Function(List<File>)? onChangedMultiple; // para múltiplos (mantido para compatibilidade)
  final void Function(XFile?)? onChangedXFile; // para single com XFile (web-compatible)
  final void Function(List<XFile>)? onChangedMultipleXFile; // para múltiplos com XFile (web-compatible)
  final String? initialImageUrl; // URL da imagem existente (para edição)
  final List<String>? initialImageUrls; // URLs das imagens existentes (para múltiplas)

  const InputImage({
    super.key,
    this.label,
    this.multiple = false,
    this.onChanged,
    this.onChangedMultiple,
    this.onChangedXFile,
    this.onChangedMultipleXFile,
    this.initialImageUrl,
    this.initialImageUrls,
  });

  @override
  State<InputImage> createState() => _InputImageState();
}

class _InputImageState extends State<InputImage> {
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedXFile; // Armazena XFile (funciona na web)
  File? _selectedImage; // Mantido para compatibilidade (pode ser null na web)
  List<XFile> _xFiles = []; // Armazena XFiles (funciona na web)
  List<File> _images = []; // Mantido para compatibilidade (pode ser vazio na web)
  bool _hasInitialImage = false;
  List<String> _initialImageUrls = []; // URLs das imagens iniciais (para múltiplas)

  @override
  void initState() {
    super.initState();
    if (widget.multiple) {
      _initialImageUrls = widget.initialImageUrls ?? [];
      _hasInitialImage = _initialImageUrls.isNotEmpty;
      if (_hasInitialImage) {
        print('DEBUG InputImage - initialImageUrls: ${widget.initialImageUrls}');
      }
    } else {
      _hasInitialImage = widget.initialImageUrl?.isNotEmpty ?? false;
      if (_hasInitialImage) {
        print('DEBUG InputImage - initialImageUrl: ${widget.initialImageUrl}');
      }
    }
  }

  Future<void> _pickImage() async {
    if (widget.multiple) {
      final pickedFiles = await _picker.pickMultiImage(imageQuality: 80);
      if (pickedFiles.isNotEmpty) {
        setState(() {
          _xFiles.addAll(pickedFiles);
          // Tenta converter XFile para File apenas se possível (mobile)
          // Na web, isso pode falhar, então não armazenamos File
          try {
            _images.addAll(pickedFiles.map((e) => File(e.path)));
          } catch (e) {
            // Na web, File não funciona, mas não é problema
            // Mantemos apenas os XFiles
          }
        });
        // Prioriza callback com XFile (web-compatible)
        if (widget.onChangedMultipleXFile != null) {
          widget.onChangedMultipleXFile!(_xFiles);
        } else if (widget.onChangedMultiple != null) {
          widget.onChangedMultiple!(_images);
        }
      }
    } else {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (picked != null) {
        setState(() {
          _selectedXFile = picked;
          // Tenta converter XFile para File apenas se possível (mobile)
          // Na web, isso pode falhar, então não armazenamos File
          try {
            _selectedImage = File(picked.path);
          } catch (e) {
            // Na web, File não funciona, mas não é problema
            // Mantemos apenas o XFile
            _selectedImage = null;
          }
        });
        // Prioriza callback com XFile (web-compatible)
        if (widget.onChangedXFile != null) {
          widget.onChangedXFile!(_selectedXFile);
        } else if (widget.onChanged != null) {
          widget.onChanged!(_selectedImage);
        }
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      // Se está removendo uma imagem inicial (URL), remove da lista de URLs
      if (index < _initialImageUrls.length) {
        _initialImageUrls.removeAt(index);
        _hasInitialImage = _initialImageUrls.isNotEmpty || _xFiles.isNotEmpty;
        // Quando remove uma imagem inicial, marca como modificado
        // Isso força o envio de uma lista vazia para remover a imagem no backend
      } else {
        // Remove uma imagem local (XFile)
        final fileIndex = index - _initialImageUrls.length;
        _xFiles.removeAt(fileIndex);
        if (fileIndex < _images.length) {
          _images.removeAt(fileIndex);
        }
      }
    });
    // Prioriza callback com XFile (web-compatible)
    if (widget.onChangedMultipleXFile != null) {
      widget.onChangedMultipleXFile!(_xFiles);
    } else if (widget.onChangedMultiple != null) {
      widget.onChangedMultiple!(_images);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: Text(
              widget.label!,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: widget.multiple ? 150 : 180,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade100,
            ),
            child: widget.multiple
                ? (_xFiles.isEmpty && _initialImageUrls.isEmpty)
                      ? const Center(
                          child: Icon(
                            Icons.add_photo_alternate,
                            size: 40,
                            color: Colors.grey,
                          ),
                        )
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _initialImageUrls.length + _xFiles.length + 1,
                          itemBuilder: (context, index) {
                            final totalImages = _initialImageUrls.length + _xFiles.length;
                            if (index == totalImages) {
                              return GestureDetector(
                                onTap: _pickImage,
                                child: Container(
                                  width: 100,
                                  margin: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey.shade400,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.grey.shade200,
                                  ),
                                  child: const Icon(Icons.add, size: 30),
                                ),
                              );
                            }
                            
                            // Se é uma imagem inicial (URL)
                            if (index < _initialImageUrls.length) {
                              return Stack(
                                children: [
                                  Container(
                                    width: 100,
                                    margin: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        _initialImageUrls[index],
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            width: 100,
                                            height: 100,
                                            color: Colors.grey.shade300,
                                            child: const Icon(
                                              Icons.broken_image,
                                              size: 30,
                                              color: Colors.grey,
                                            ),
                                          );
                                        },
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return Container(
                                            width: 100,
                                            height: 100,
                                            color: Colors.grey.shade300,
                                            child: const Center(
                                              child: CircularProgressIndicator(),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: () => _removeImage(index),
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: Colors.black54,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }
                            
                            // É uma imagem local (XFile)
                            final fileIndex = index - _initialImageUrls.length;
                            return Stack(
                              children: [
                                Container(
                                  width: 100,
                                  margin: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: FutureBuilder<Uint8List>(
                                    future: _xFiles[fileIndex].readAsBytes(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return Container(
                                          width: 100,
                                          height: 100,
                                          color: Colors.grey.shade300,
                                          child: const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        );
                                      }
                                      if (snapshot.hasData) {
                                        return ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Image.memory(
                                            snapshot.data!,
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                          ),
                                        );
                                      }
                                      // Fallback: tenta usar File se disponível
                                      if (fileIndex < _images.length) {
                                        return ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Image.file(
                                            _images[fileIndex],
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                          ),
                                        );
                                      }
                                      return Container(
                                        width: 100,
                                        height: 100,
                                        color: Colors.grey.shade300,
                                        child: const Icon(
                                          Icons.broken_image,
                                          size: 30,
                                          color: Colors.grey,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () => _removeImage(index),
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        )
                : _selectedXFile == null && !_hasInitialImage
                ? const Center(
                    child: Icon(
                      Icons.add_a_photo,
                      size: 40,
                      color: Colors.grey,
                    ),
                  )
                : Stack(
                    children: [
                      ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                        child: _selectedXFile != null
                            ? FutureBuilder<Uint8List>(
                                future: _selectedXFile!.readAsBytes(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return Container(
                                      height: 180,
                                      color: Colors.grey.shade300,
                                      child: const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  }
                                  if (snapshot.hasData) {
                                    return Image.memory(
                                      snapshot.data!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: 180,
                                    );
                                  }
                                  // Fallback: tenta usar File se disponível
                                  if (_selectedImage != null) {
                                    return Image.file(
                                      _selectedImage!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: 180,
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              )
                            : widget.initialImageUrl != null
                                ? Image.network(
                                    widget.initialImageUrl!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: 180,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        height: 180,
                                        color: Colors.grey.shade300,
                                        child: const Center(
                                          child: Icon(
                                            Icons.broken_image,
                                            size: 40,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      );
                                    },
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        height: 180,
                                        color: Colors.grey.shade300,
                                        child: const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      );
                                    },
                                  )
                                : const SizedBox.shrink(),
                      ),
                      if (_hasInitialImage && _selectedXFile == null)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _hasInitialImage = false;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
