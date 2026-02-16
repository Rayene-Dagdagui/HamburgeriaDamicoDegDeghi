import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FlaskServiceService } from '../../services/flask-service.service';

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './dashboard.component.html',
  styleUrls: ['./dashboard.component.css']
})
export class DashboardComponent implements OnInit {
  orders: any[] = [];
  loading = false;
  error = '';

  // Contatori per stati
  pendingCount = 0;
  preparingCount = 0;
  readyCount = 0;
  totalToday = 0;
  totalRevenue = 0;

  constructor(private flaskService: FlaskServiceService) {}

  ngOnInit() {
    this.loadOrders();
    // Aggiorna ogni 10 secondi
    setInterval(() => this.loadOrders(), 10000);
  }

  loadOrders() {
    this.loading = true;
    this.flaskService.getAllOrders().subscribe({
      next: (response) => {
        this.orders = response.data;
        this.calculateStats();
        this.loading = false;
      },
      error: (err) => {
        this.error = 'Errore caricamento ordini';
        this.loading = false;
      }
    });
  }

  calculateStats() {
    this.pendingCount = this.orders.filter(o => o.status === 'pending').length;
    this.preparingCount = this.orders.filter(o => o.status === 'preparing').length;
    this.readyCount = this.orders.filter(o => o.status === 'ready').length;
    this.totalToday = this.orders.length;
    this.totalRevenue = this.orders.reduce((sum, o) => sum + parseFloat(o.total_price), 0);
  }
}
