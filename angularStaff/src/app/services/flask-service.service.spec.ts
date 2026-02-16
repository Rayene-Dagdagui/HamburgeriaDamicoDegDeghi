import { TestBed } from '@angular/core/testing';

import { FlaskServiceService } from './flask-service.service';

describe('FlaskServiceService', () => {
  let service: FlaskServiceService;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(FlaskServiceService);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
