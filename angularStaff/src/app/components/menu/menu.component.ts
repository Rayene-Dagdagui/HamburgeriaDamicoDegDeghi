import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { FlaskServiceService } from '../../services/flask-service.service';

@Component({
  selector: 'app-menu',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './menu.component.html',
  styleUrls: ['./menu.component.css']
})
export class MenuComponent implements OnInit {
  products: any[] = [];
  categories: any[] = [];
  selectedCategoryId: number | null = null;
  loading = false;
  error = '';
  
  // Form per aggiungere/modificare prodotto
  showProductForm = false;
  formData = {
    id: null,
    name: '',
    description: '',
    price: 0,
    category_id: null,
    image_url: ''
  };

  // Form per aggiungere/modificare categoria
  showCategoryForm = false;
  categoryFormData = {
    id: null,
    name: '',
    description: '',
    icon: '🍔',
    order_position: 0
  };

  constructor(private flaskService: FlaskServiceService) {}

  ngOnInit() {
    this.loadCategories();
    this.loadAllProducts();
  }

  // ======== CATEGORIE ========

  loadCategories() {
    this.flaskService.getAllCategories().subscribe({
      next: (response) => {
        this.categories = response.data;
        if (this.categories.length > 0 && !this.selectedCategoryId) {
          this.selectedCategoryId = this.categories[0].id;
        }
      },
      error: (err) => console.error('Errore caricamento categorie', err)
    });
  }

  openCategoryForm(category: any) {
    // apri il modulo soltanto per modifica; l'interfaccia non permette la creazione
    if (!category) {
      return; // ignoriamo
    }
    this.categoryFormData = { ...category };
    this.showCategoryForm = true;
  }

  closeCategoryForm() {
    this.showCategoryForm = false;
  }

  saveCategory() {
    if (!this.categoryFormData.name) {
      this.error = 'Il nome della categoria è obbligatorio';
      return;
    }

    if (this.categoryFormData.id) {
      // Aggiorna categoria esistente
      this.flaskService.updateCategory(this.categoryFormData.id, this.categoryFormData).subscribe({
        next: (response) => {
          this.loadCategories();
          this.closeCategoryForm();
        },
        error: (err) => {
          this.error = 'Errore aggiornamento categoria';
        }
      });
    } else {
      // non dovrebbe capitare perché l'interfaccia non permette creazione
      this.error = 'Creazione di nuove categorie non consentita';
    }
  }

  deleteCategory(categoryId: number) {
    if (confirm('Sei sicuro di voler eliminare questa categoria?')) {
      this.flaskService.deleteCategory(categoryId).subscribe({
        next: (response) => {
          this.loadCategories();
          this.loadAllProducts();
        },
        error: (err) => {
          this.error = 'Errore eliminazione categoria';
        }
      });
    }
  }

  // ======== PRODOTTI ========

  loadAllProducts() {
    this.loading = true;
    this.flaskService.getAllProducts().subscribe({
      next: (response) => {
        this.products = response.data;
        this.loading = false;
      },
      error: (err) => {
        this.error = 'Errore caricamento prodotti';
        this.loading = false;
      }
    });
  }

  onCategoryChange() {
    if (this.selectedCategoryId === null) {
      this.loadAllProducts();
    } else {
      this.loadProductsByCategory(this.selectedCategoryId);
    }
  }

  loadProductsByCategory(categoryId: number) {
    this.loading = true;
    this.flaskService.getProductsByCategory(categoryId).subscribe({
      next: (response) => {
        this.products = response.data;
        this.loading = false;
      },
      error: (err) => {
        this.error = 'Errore caricamento prodotti';
        this.loading = false;
      }
    });
  }

  openProductForm(product: any = null) {
    if (product) {
      this.formData = { ...product };
    } else {
      this.formData = {
        id: null,
        name: '',
        description: '',
        price: 0,
        category_id: this.selectedCategoryId || (this.categories[0]?.id || null),
        image_url: ''
      };
    }
    this.showProductForm = true;
  }

  closeProductForm() {
    this.showProductForm = false;
  }

  saveProduct() {
    if (!this.formData.name || !this.formData.price || !this.formData.category_id) {
      this.error = 'Compila tutti i campi obbligatori';
      return;
    }

    if (this.formData.id) {
      // Aggiorna
      this.flaskService.updateProduct(this.formData.id, this.formData).subscribe({
        next: (response) => {
          this.loadAllProducts();
          this.closeProductForm();
        },
        error: (err) => {
          this.error = 'Errore aggiornamento prodotto';
        }
      });
    } else {
      // Crea nuovo
      this.flaskService.createProduct(this.formData).subscribe({
        next: (response) => {
          this.loadAllProducts();
          this.closeProductForm();
        },
        error: (err) => {
          this.error = 'Errore creazione prodotto';
        }
      });
    }
  }

  deleteProduct(productId: number) {
    if (confirm('Sei sicuro di voler eliminare questo prodotto?')) {
      this.flaskService.deleteProduct(productId).subscribe({
        next: (response) => {
          this.loadAllProducts();
        },
        error: (err) => {
          this.error = 'Errore eliminazione prodotto';
        }
      });
    }
  }

  getFilteredProducts(): any[] {
    if (this.selectedCategoryId === null) {
      return this.products;
    }
    return this.products.filter(p => p.category_id === this.selectedCategoryId);
  }

  getCategoryName(categoryId: number): string {
    const category = this.categories.find(c => c.id === categoryId);
    return category ? category.name : 'Sconosciuta';
  }

  getCategoryIcon(categoryId: number): string {
    const category = this.categories.find(c => c.id === categoryId);
    return category ? category.icon : '🍔';
  }
}
