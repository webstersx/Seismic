//
//  SeismicMapViewController.m
//  Seismic
//
//  Created by Shawn Webster on 2014-10-15.
//  Copyright (c) 2014 Shawn Webster. All rights reserved.
//

#import "SeismicMapViewController.h"
#import "Earthquake.h"
#import <MapKit/MapKit.h>
#import "SeismicMapAnnotation.h"

#import "SeismicDB.h"

#define kSeismicMapAnnotationViewIdentifier @"kSeismicMapAnnotationViewIdentifier"

@interface SeismicMapViewController () <MKMapViewDelegate>

@property (retain, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation SeismicMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //showing just one event or all events?
    NSArray *annotations = nil;
    if (self.event) {
        [self updateTitleForEvent:self.event];
        annotations = [self annotationsForEvents:@[self.event]];
    } else {
        
        self.title = @"All events";
        annotations = [self annotationsForEvents:[[SeismicDB shared] events]];
        
    }
    
    [self.mapView addAnnotations:annotations];
    
    if (self.event) {
        [self.mapView selectAnnotation:[annotations firstObject] animated:NO];
    }
}

/**
 Converts an array of Earthquake objects to SeismicMapAnnotations
 @param events an array of Earthquake events
 @returns An array of SeismicMapAnnotation objects
 */
- (NSArray*) annotationsForEvents:(NSArray*)events {
    NSMutableArray *annotations = [NSMutableArray array];
    
    for (Earthquake *event in events) {
    
        [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(event.lat.doubleValue,
                                                                     event.lon.doubleValue)];
        
        SeismicMapAnnotation *annotation = [[SeismicMapAnnotation alloc] init];
        annotation.event = event;
        
        [annotations addObject:annotation];
    
    }
    
    return annotations;
}

- (void) updateTitleForEvent:(Earthquake*)event {
    if (event) {
        self.title = [NSString stringWithFormat:@"Magnitude %.1f", event.magnitude.floatValue];
    } else {
        self.title = @"All events";
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_mapView release];
    
    [_event release];
    _event = nil;
    
    [super dealloc];
}

#pragma mark - Map View Delegate Methods

- (void) mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    
    if (!self.event) {
        [self updateTitleForEvent:nil];
    }
    
}

- (void) mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if (!self.event) {
        SeismicMapAnnotation *annotation = view.annotation;
        
        if ([annotation isKindOfClass:[SeismicMapAnnotation class]]) {
            [self updateTitleForEvent:annotation.event];
        }
    }
}


- (MKAnnotationView*) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    MKPinAnnotationView *annotationView = nil;
    
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    } else {
        annotationView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:kSeismicMapAnnotationViewIdentifier];
        
        if (!annotationView) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                                          reuseIdentifier:kSeismicMapAnnotationViewIdentifier];
            [annotationView setPinColor:MKPinAnnotationColorRed];
            annotationView.canShowCallout = YES;
        }
    }
    
    return annotationView;
}


@end
