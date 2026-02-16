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
  categories: string[] = [];
  selectedCategory = 'all';
  loading = false;
  error = '';
  showForm = false;

  // Form per aggiungere/modificare prodotto
  formData = {
    id: null,
    name: '',
    description: '',
    price: 0,
    category: '',
    image_url: ''
  };

  constructor(private flaskService: FlaskServiceService) {}

  ngOnInit() {
    this.loadCategories();
    this.loadAllProducts();
  }

  loadCategories() {
    this.flaskService.getCategories().subscribe({
      next: (response) => {
        this.categories = response.data;
        if (this.categories.length > 0 && !this.selectedCategory) {
          this.selectedCategory = this.categories[0];
        }
      },
      error: (err) => console.error('Errore caricamento categorie', err)
    });
  }

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
    if (this.selectedCategory === 'all') {
      this.loadAllProducts();
    } else {
      this.loadProductsByCategory(this.selectedCategory);
    }
  }

  loadProductsByCategory(category: string) {
    this.loading = true;
    this.flaskService.getProductsByCategory(category).subscribe({
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

  openForm(product: any = null) {
    if (product) {
      this.formData = { ...product };
    } else {
      this.formData = {
        id: null,
        name: '',
        description: '',
        price: 0,
        category: this.categories[0] || '',
        image_url: ''
      };
    }
    this.showForm = true;
  }

  closeForm() {
    this.showForm = false;
  }

  saveProduct() {
    if (!this.formData.name || !this.formData.price || !this.formData.category) {
      this.error = 'Compila tutti i campi obbligatori';
      return;
    }

    if (this.formData.id) {
      // Aggiorna
      this.flaskService.updateProduct(this.formData.id, this.formData).subscribe({
        next: (response) => {
          this.loadAllProducts();
          this.closeForm();
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
          this.closeForm();
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
    if (this.selectedCategory === 'all') {
      return this.products;
    }
    return this.products.filter(p => p.category === this.selectedCategory);
  }
}
